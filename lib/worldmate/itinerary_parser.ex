defmodule Worldmate.ItineraryParser do
  @moduledoc """
  Parses the XML response from Worldmate into easily consumable structs.
  @see http://www.worldmate.com/schemas/worldmate-api-v1.xsd
  """

  import SweetXml
  alias Worldmate.{Aircraft, Airport, Flight, Movement, ParseResult}

  @doc """
  SweetXml relies on `:xmerl_scan.string/1` to parse XML documents
  When the document is invalid, it `throw`s an `:exit`. This function wraps
  the call to return a standard `{:ok, result}` or `{:error, reason}`
  """
  def parse_xml(xmlstr) when is_binary(xmlstr) do
    {:ok, xmlstr |> SweetXml.parse() |> root()}
  catch
    :exit, e -> {:error, e}
  end

  def parse_xml!(xmlstr) when is_binary(xmlstr) do
    case parse_xml(xmlstr) do
      {:ok, result} -> result
      {:error, _} -> nil
    end
  end

  @doc """
  Convert the entire response into a single map
  """
  def to_parse_result(nil), do: nil

  def to_parse_result(root) when is_tuple(root) do
    %ParseResult{
      status: status(root),
      request_id: request_id(root),
      headers: headers(root),
      flights: flights(root)
    }
  end

  @doc """
  Processing status.
  See [API docs](https://developers.worldmate.com/documentation.php#_Toc317625928)
  """
  def status(root) when is_tuple(root) do
    root
    |> xpath(~x"//status/text()"s)
  end

  def request_id(root) when is_tuple(root) do
    root |> xpath(~x"//@request-id"s)
  end

  @doc """
  Get the parsed email headers as a map with the lowercased header names as the keys
  """
  def headers(root) when is_tuple(root) do
    root
    |> xpath(
      ~x"//headers/header"l,
      name: ~x"./@name"s,
      value: ~x"./@value"s
    )
    |> Enum.reduce(%{}, fn x, acc ->
      Map.put(acc, String.downcase(x.name), x.value)
    end)
  end

  def flights(root) when is_tuple(root) do
    root
    |> xpath(~x"//items/flight"l)
    |> Enum.map(&parse_flight/1)
  end

  defp root(xmldoc) when is_tuple(xmldoc) do
    # We could use /* for the root, but using the expected name of the root
    # element ensures we're parsing a document we know how to work with
    xmldoc
    |> xpath(~x"//ns2:worldmate-parsing-result"e)
  end

  defp parse_flight(node) when is_tuple(node) do
    node
    |> xmap(
      confirmation_number:
        ~x"./booking-details/confirmation-number/text()"s |> transform_by(&groom_string/1),
      operator: ~x"./operated-by" |> transform_by(&parse_flight_code/1),
      flight_code: ~x"./details" |> transform_by(&parse_flight_code/1),
      departure: ~x"./departure" |> transform_by(&parse_movement/1),
      arrival: ~x"./arrival" |> transform_by(&parse_movement/1),
      aircraft: ~x"./aircraft" |> transform_by(&parse_aircraft/1),
      duration_minutes: ~x"./duration/text()"io,
      distance_miles: ~x"./distance-in-miles/text()"io,
      seat_class: ~x"./class-type/text()"s |> transform_by(&groom_string/1),
      seat: ~x"./traveler/seat/text()"s |> transform_by(&groom_string/1)
    )
    |> put_codeshare()
    |> to_struct(Flight)
  end

  # When a flight has both the `operator` and `flight_code`, the `operator` is
  # the real and proper flight code and `flight_code` is the codeshare. So
  # in those cases, switch them. Otherwise leave everything alone.
  defp put_codeshare(%{operator: nil} = data) do
    data
    |> Map.delete(:operator)
    |> Map.put(:codeshare, nil)
  end

  defp put_codeshare(%{operator: operator, flight_code: codeshare} = data) do
    data
    |> Map.delete(:operator)
    |> Map.delete(:flight_code)
    |> Map.put(:flight_code, operator)
    |> Map.put(:codeshare, codeshare)
  end

  defp parse_flight_code(nil), do: nil

  defp parse_flight_code(node) do
    node
    |> xmap(
      airline_code: ~x"./@airline-code"s,
      flight_number: ~x"./@number"s
    )
  end

  defp parse_movement(nil), do: nil

  defp parse_movement(node) do
    node
    |> xmap(
      local_time: ~x"./local-date-time/text()"s |> transform_by(&parse_date_time/1),
      utc_time: ~x"./utc-date-time/text()"s |> transform_by(&parse_date_time/1),
      terminal: ~x"./terminal/text()"s |> transform_by(&groom_string/1),
      gate: ~x"./gate/text()"s |> transform_by(&groom_string/1)
    )
    |> to_struct(Movement)
    |> Map.put(:airport, parse_airport(node))
  end

  defp parse_airport(nil), do: nil

  defp parse_airport(node) do
    node
    |> xmap(
      iata_code: ~x"./airport-code/text()"s,
      name: ~x"./name/text()"s,
      latitude: ~x"./latitude/text()"f,
      longitude: ~x"./longitude/text()"f
    )
    |> to_struct(Airport)
  end

  defp parse_aircraft(nil), do: nil

  defp parse_aircraft(node) do
    node
    |> xmap(
      code: ~x"./@code"s,
      description: ~x"./@name"s
    )
    |> to_struct(Aircraft)
  end

  defp parse_date_time(nil), do: nil

  defp parse_date_time(timestr) do
    case DateTime.from_iso8601(timestr) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end

  # trim a string and convert empty string to `nil`
  defp groom_string(nil), do: nil

  defp groom_string(str) when is_binary(str) do
    str
    |> String.trim()
    |> case do
      "" -> nil
      s -> s
    end
  end

  # helper to use in a pipeline to convert a map with values to a struct
  defp to_struct(map, type) do
    struct(type, map)
  end
end
