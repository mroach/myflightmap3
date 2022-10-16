defmodule Myflightmap.Travel.WorldmateTripImporterTest do
  use Myflightmap.DataCase
  import Myflightmap.Factory

  alias Myflightmap.Travel.WorldmateTripImporter

  doctest Myflightmap.Travel.WorldmateTripImporter

  test "import/1" do
    # create a user with a trip email ID matching the worldmate 'to' email header
    user = insert(:user, trip_email_id: "apidemo")

    # create the airports and airline we need for the flight
    insert(:airport,
      iata_code: "FRA",
      coordinates: %Point{x: 50.033333, y: 8.570556},
      timezone: "Europe/Berlin"
    )

    insert(:airport,
      iata_code: "JFK",
      coordinates: %Point{x: 40.63980103, y: -73.77890015},
      timezone: "America/New_York"
    )

    insert(:airline, iata_code: "SQ")

    xmlstr = File.read!("./test/fixtures/worldmate-single.xml")
    {:ok, result} = WorldmateTripImporter.import(xmlstr)

    %{trip: trip} = result

    assert trip.name == "Fwd: Your seat selection confirmation ABC123"
    assert trip.user_id == user.id

    %{{:flight, 1} => flight} = result

    assert flight.user_id == user.id
  end
end
