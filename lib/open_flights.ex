defmodule OpenFlights do
  @moduledoc """
  Fetches data from [openflights.org](https://openflights.org/data.html)

  There's no API, so CSV data has to be downloaded and parsed.
  """

  require Logger
  use Tesla

  alias Myflightmap.Transport

  NimbleCSV.define(OpenFlights.AirportsCSV, separator: ",", escape: "\"")

  plug Tesla.Middleware.BaseUrl,
       "https://raw.githubusercontent.com/jpatokal/openflights/master/"

  @doc """
  Get all airports and return a map compatible with the `Airport` struct.
  """
  def get_airports do
    {:ok, %{body: csv_string}} = get("data/airports.dat")
    {:ok, csv_stream} = StringIO.open(csv_string)

    csv_stream
    |> IO.binstream(:line)
    |> OpenFlights.AirportsCSV.parse_stream(skip_headers: false)
    |> Stream.map(fn [
                       _id,
                       name,
                       city,
                       country,
                       iata,
                       icao,
                       lat,
                       lon,
                       _altitude,
                       _timezone,
                       _dst,
                       timezone_id,
                       _type,
                       _source
                     ] ->
      {lat, _} = Float.parse(lat)
      {lon, _} = Float.parse(lon)

      %{
        full_name: name,
        city: city,
        country: country_name_to_code(country),
        iata_code: iata,
        icao_code: icao,
        coordinates: {lat, lon},
        timezone: timezone_id,
        metro_code: Transport.get_metro_code(iata)
      }
      |> replace_null_placeholders
      |> Map.put(:common_name, gen_common_name(name))
    end)
  end

  @doc """
  Removes the words: "Airport", "International", "Regional", from the name.

  Examples:
      iex> OpenFlights.gen_common_name("London Heathrow Airport")
      "London Heathrow"

      iex> OpenFlights.gen_common_name("Tokyo Haneda International Airport")
      "Tokyo Haneda"

      iex> OpenFlights.gen_common_name("Asheville Regional Airport")
      "Asheville"
  """
  def gen_common_name(name) do
    ~w[Airport Regional International]
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(name, fn word, s -> String.replace(s, ~r/\b#{word}\b/, "") end)
    |> String.trim()
    |> case do
      "" ->
        name

      generated ->
        generated
    end
  end

  @doc """
  Convert country name to code.

  Examples:
      iex> OpenFlights.country_name_to_code("United Kingdom")
      "GB"

      iex> OpenFlights.country_name_to_code("Sao Tome and Principe")
      "ST"
  """
  def country_name_to_code("Cote d'Ivoire"), do: "CI"
  def country_name_to_code("Congo (Brazzaville)"), do: "CG"
  def country_name_to_code("Congo (Kinshasa)"), do: "CD"
  def country_name_to_code("Sao Tome and Principe"), do: "ST"
  def country_name_to_code("Midway Islands"), do: "US"

  def country_name_to_code(name) do
    case Countries.filter_by(:unofficial_names, name) do
      [%{alpha2: code} | _tail] ->
        code

      _ ->
        Logger.info("Unable to find an ISO country code for #{name}")
        nil
    end
  end

  # OpenFlights uses the string `\N` to represent nulls
  # That's understood by MySQL and nothing else. Replace `\N` with `nil`
  defp replace_null_placeholders(airport) do
    airport
    |> Enum.into(%{}, fn {k, v} -> {k, replace_null(v)} end)
  end

  defp replace_null("\\N"), do: nil
  defp replace_null(val), do: val
end
