defmodule Myflightmap.Travel.WorldmateTripImporter do
  require Logger
  alias Ecto.Multi
  alias Myflightmap.{Accounts, Repo, Transport, Travel}
  alias Myflightmap.Travel.Flight
  alias Worldmate.ParseResult

  def import(xmlstr) do
    result = Worldmate.parse_xml_itinerary!(xmlstr)

    with :ok <- check_status(result),
         {:ok, user} <- load_user(result) do
      multi =
        Multi.new()
        |> Multi.run(:trip, fn _, _ ->
          Travel.get_or_create_trip_by_name(user, trip_name(result))
        end)

      multi =
        result.flights
        |> Enum.with_index(1)
        |> Enum.reduce(multi, fn {raw_data, index}, acc ->
          Multi.insert(acc, {:flight, index}, fn %{trip: trip} ->
            raw_data
            |> map_flight_schema
            |> Map.put(:user, user)
            |> Map.put(:trip, trip)
            |> Flight.changeset(%{})
          end)
        end)

      Repo.transaction(multi)
    else
      err -> err
    end
  end

  # Only process the result if Worldmate said it parsed the itinerary successfully
  defp check_status(%ParseResult{status: "SUCCESS"}), do: :ok
  defp check_status(_), do: {:error, :worldmate_not_successful}

  def load_user(%ParseResult{headers: headers}) do
    case headers |> Map.get("to") |> recipient() do
      {:ok, user} -> load_user(user)
      err -> err
    end
  end

  def load_user(trip_email_id) when is_binary(trip_email_id) do
    case Accounts.get_user_by_trip_email_id(trip_email_id) do
      nil ->
        Logger.error("No user found with trip email '#{trip_email_id}'")
        {:error, :user_not_found}

      user ->
        {:ok, user}
    end
  end

  @doc """
  Determine if the recipient of the forwarded itinerary is valid.
  Users can only send them to our domains.

  Example:
      iex> Myflightmap.Travel.WorldmateTripImporter.recipient("asdqwe123@trips.myflightmap.com")
      {:ok, "asdqwe123"}

      iex> Myflightmap.Travel.WorldmateTripImporter.recipient("asdqwe123@gmail.com")
      {:error, :invalid_domain}
  """
  def recipient(email) do
    [user, domain | _] = String.split(email, "@")

    case Enum.member?(valid_domains(), domain) do
      true -> {:ok, user}
      _ -> {:error, :invalid_domain}
    end
  end

  def trip_name(%Worldmate.ParseResult{headers: headers}) do
    headers |> Map.get("subject")
  end

  def map_flight_schema(%Worldmate.Flight{} = wmflight) do
    depart_airport = Transport.get_airport_by_iata!(wmflight.departure.airport.iata_code)
    arrive_airport = Transport.get_airport_by_iata!(wmflight.arrival.airport.iata_code)
    airline = Transport.get_airline_by_iata!(wmflight.flight_code.airline_code)

    %Flight{
      depart_airport: depart_airport,
      arrive_airport: arrive_airport,
      airline: airline,
      confirmation_number: wmflight.confirmation_number,
      seat: wmflight.seat,
      seat_class: wmflight.seat_class,
      flight_code: wmflight.flight_code.airline_code <> wmflight.flight_code.flight_number
    }
    |> Flight.put_movement_date_time(:depart, wmflight.departure.local_time)
    |> Flight.put_movement_date_time(:arrive, wmflight.arrival.local_time)
  end

  defp valid_domains do
    :myflightmap
    |> Application.get_env(__MODULE__)
    |> Keyword.fetch!(:valid_domains)
  end
end
