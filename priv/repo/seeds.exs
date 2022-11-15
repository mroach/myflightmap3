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

import Ecto.Query

alias Myflightmap.Repo
alias Myflightmap.Transport.{AircraftType, Airline, Airport}
alias Myflightmap.Travel.Flight

airline_attrs =
  OpenFlights.get_airlines()
  |> Stream.map(fn attrs ->
    attrs = Map.take(attrs, [:name, :iata_code, :icao_code, :country])
    Airline.changeset(%Airline{}, attrs)
  end)
  |> Stream.filter(fn changeset ->
    unless changeset.valid? do
      IO.puts("Invalid airline:")
      IO.inspect(changeset)
    end

    changeset.valid?
  end)
  |> Stream.map(fn changeset ->
    Map.take(
      changeset.changes,
      [:name, :iata_code, :icao_code, :country]
    )
  end)
  |> Enum.chunk_every(100)
  |> Enum.each(fn batch ->
    IO.inspect("Here comes a batch:")
    IO.inspect(batch)
    Repo.insert_all(Myflightmap.Transport.Airline, batch)
  end)

OpenFlights.get_airports()
|> Stream.filter(fn ap -> ap[:iata_code] && ap[:timezone] end)
|> Stream.map(fn attrs -> Airport.changeset(%Airport{}, attrs) end)
|> Stream.filter(fn changeset ->
  unless changeset.valid? do
    IO.puts("Invalid airport:")
    IO.inspect(changeset)
  end

  changeset.valid?
end)
|> Stream.map(&(&1.changes))
|> Enum.chunk_every(500)
|> Enum.each(fn batch ->
  Repo.insert_all(Airport, batch)
end)

for path <- Path.wildcard("priv/data/icao/aircraft_types/*.json") do
  path
  |> File.read!()
  |> Jason.decode!(%{keys: :atoms})
  |> Enum.map(fn data ->
    description =
      [data.model_no, data.model_name]
      |> Enum.map(&(to_string(&1)))
      |> Enum.reject(&(&1 == ""))
      |> Enum.join(" ")

    %{
      manufacturer_code: data.manufacturer_code,
      description: description,
      engine_type: data.engine_type,
      engine_count: data.engine_count,
      icao_code: data.tdesig
    }
  end)
  |> (&(Repo.insert_all(AircraftType, &1))).()
end
