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
