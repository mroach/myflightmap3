defmodule Myflightmap.Queries.TravelTest do
  use Myflightmap.DataCase

  import Myflightmap.Factory

  test "airport_movements/1" do
    # Simulate a flight route like BOS-LHR-CPH
    # Two flights, four movements, three airports. LHR should get a "2"
    airport = insert(:airport, iata_code: "LHR")

    f1 = insert(:flight, arrive_airport: airport)
    f2 = insert(:flight, depart_airport: airport)

    assert f2.depart_airport.id == f1.arrive_airport.id

    result = Myflightmap.Queries.Travel.top_airports() |> Repo.all()

    assert 2 == Enum.find(result, fn a -> a.airport.id == airport.id end).movements
  end
end
