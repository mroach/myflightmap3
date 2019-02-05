defmodule Sita do
  require Logger
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://airport.api.aero"
  plug Tesla.Middleware.Headers, [
    {"x-apikey", api_key()},
    {"accept", "application/json"}
  ]
  plug Tesla.Middleware.JSON

  @airport_fields ~w[city country iatacode icaocode lat lng name timezone]

  @moduledoc """
  SITA (developer.aero) has an API that provides airport info that we need:
  IATA, ICAO, Name, City, Country, Timezone ID, Coordinates
  """
  def get_airports do
    with {:ok, resp} <- get("/airport/v2/airports"),
         %{body: %{"airports" => airports}} <- resp do
      {:ok, Enum.map(airports, &groom_airport/1) }
    else
      error -> error
    end
  end

  @doc """
  Get a specific airport by IATA (3-char) code

  Example:
      iex> {:ok, airport} = Sita.get_airport("CPH")
      ...> Map.take(airport, [:city, :country_code, :timezone])
      %{city: "Copenhagen", country_code: "DK", timezone: "Europe/Copenhagen"}
  """
  def get_airport(code) do
    with {:ok, resp} <- get("/airport/v2/airport/#{ code }"),
         %{body: %{"airports" => [airport | _tail]}} <- resp do
      {:ok, airport |> groom_airport}
    else
      error -> error
    end
  end

  def api_key, do: System.get_env("SITA_API_KEY")

  @doc """
  Lookup the ISO country code based on the country name provided in the API.

  Use the "unofficial names" list as it's far easier to find what we want.
  For example: Macedonia, South Korea, Iran, United States, United Kingdom, Russia.
  None of these are the official names and wouldn't be found with `:name`

  Examples:
      iex> Sita.country_name_to_code("United Kingdom")
      "GB"

      iex> Sita.country_name_to_code("Burma")
      "MM"

      iex> Sita.country_name_to_code("Sweden")
      "SE"

      iex> Sita.country_name_to_code("bogusland")
      nil
  """
  def country_name_to_code("Burma"), do: "MM"
  def country_name_to_code("Congo (Kinshasa)"), do: "CD"
  def country_name_to_code("Congo (Brazzaville)"), do: "CG"
  def country_name_to_code("Sao Tome and Principe"), do: "ST"
  def country_name_to_code("Netherlands Antilles"), do: "NL"
  def country_name_to_code("North Korea"), do: "KP"
  def country_name_to_code("Cote d'Ivoire"), do: "CI"
  def country_name_to_code(name) do
    case Countries.filter_by(:unofficial_names, name) do
      [%{alpha2: code} | _tail] ->
        code
      _ ->
        Logger.info "Unable to find an ISO country code for #{ name }"
        nil
    end
  end

  defp groom_airport(airport) do
    airport
    |> Map.take(@airport_fields)
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
    |> put_iso_country_code
  end

  defp put_iso_country_code(%{country: name} = airport) when is_binary(name) do
    case country_name_to_code(name) do
      nil -> airport
      code -> airport |> Map.put(:country_code, code)
    end
  end
  defp put_iso_country_code(airport), do: airport
end
