# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Myflightmap.Repo.insert!(%Myflightmap.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Myflightmap.Transport.Airline
alias Myflightmap.Transport.Airport

airlines = [
  %Airline{
    iata_code: "LH", icao_code: "DLH", country: "DE", commenced_on: ~D[1953-01-06],
    name: "Lufthansa",
    alliance: "staralliance"
  },
  %Airline{
    iata_code: "SR", icao_code: "SWR", country: "CH", commenced_on: ~D[1931-03-26],
    name: "Swissair",
    ceased_on: ~D[2002-03-31]
  },
  %Airline{
    iata_code: "LX", icao_code: "CRX", country: "CH", commenced_on: ~D[1978-11-18],
    name: "Crossair",
    ceased_on: ~D[2002-03-31]
  },
  %Airline{
    iata_code: "LX", icao_code: "SWR", country: "CH", commenced_on: ~D[2002-03-31],
    name: "Swiss International Air Lines",
    alliance: "staralliance"
  },
  %Airline{
    iata_code: "SK", icao_code: "SAS", country: "SE", commenced_on: ~D[1946-08-01],
    name: "SAS Scandinavian Airlines",
    alliance: "staralliance"
  },
  %Airline{
    iata_code: "KL", icao_code: "KLM", country: "NL", commenced_on: ~D[1919-08-07],
    name: "KLM Royal Dutch Airlines",
    alliance: "skyteam"
  },
  %Airline{
    iata_code: "SQ", icao_code: "SIA", country: "SG", commenced_on: ~D[1972-08-01],
    name: "Singapore Airlines",
    alliance: "skyteam"
  },
  %Airline{
    iata_code: "QF", icao_code: "QFA", country: "AU", commenced_on: ~D[1921-03-01],
    name: "Qantas",
    alliance: "oneworld"
  },
]

for airline <- airlines do
  if nil == Myflightmap.Repo.get_by(Airline, Map.take(airline, [:iata_code, :name])) do
    {:ok, _record} = airline
      |> Map.from_struct
      |> Myflightmap.Transport.create_airline
  else
    IO.puts "Airline #{airline.name} already exists"
  end
end


airports = [
  %Airport{
    iata_code: "SIN", icao_code: "WSSS", country: "SG",
    coordinates: {1.359167, 103.989444}, timezone: "Asia/Singapore",
    city: "Singapore", common_name: "Singapore Changi"
  },
  %Airport{
    iata_code: "HND", icao_code: "RJTT", country: "JP", metro_code: "TYO",
    coordinates: {35.553333, 139.781111}, timezone: "Asia/Tokyo",
    city: "Tokyo", common_name: "Tokyo Haneda",
  },
  %Airport{
    iata_code: "NRT", icao_code: "RJAA", country: "JP", metro_code: "TYO",
    coordinates: {35.765278, 140.385556}, timezone: "Asia/Tokyo",
    city: "Tokyo", common_name: "Tokyo Narita",
  },
  %Airport{
    iata_code: "HAM", icao_code: "EDDH", country: "DE", city: "Hamburg",
    coordinates: {53.630278, 9.991111}, timezone: "Europe/Berlin",
    common_name: "Hamburg Airport"
  },
  %Airport{
    iata_code: "BKK", icao_code: "VTBS", country: "TH", metro_code: "BKK",
    coordinates: {13.6925, 100.75}, timezone: "Asia/Bangkok",
    city: "Bangkok", common_name: "Bangkok Suvarnabhumi"
  },
  %Airport{
    iata_code: "DMK", icao_code: "VTBD", country: "TH", metro_code: "BKK",
    coordinates: {13.9125, 100.606667}, timezone: "Asia/Bangkok",
    city: "Bangkok", common_name: "Bangkok Don Mueang"
  },
  %Airport{
    iata_code: "LHR", icao_code: "EGLL", country: "GB", metro_code: "LON",
    coordinates: {51.4775, -0.461389}, timezone: "Europe/London",
    city: "London", common_name: "London Heathrow"
  },
  %Airport{
    iata_code: "LGW", icao_code: "EGKK", country: "GB", metro_code: "LON",
    coordinates: {51.148056, -0.190278}, timezone: "Europe/London",
    city: "London", common_name: "London Gatwick"
  }
]

for airport <- airports do
  if nil == Myflightmap.Repo.get_by(Airport, Map.take(airport, [:iata_code])) do
    {:ok, _record} = airport |> Map.from_struct |> Myflightmap.Transport.create_airport
  else
    IO.puts "Airport #{airport.iata_code} already exists"
  end
end
