defmodule OpenFlightsTest do
  use ExUnit.Case
  import Tesla.Mock

  setup do
    mock fn
      %{method: :get, url: "https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat"} ->
        %Tesla.Env{
          status: 200,
          body: ~S"""
          741,"Gävle Sandviken Airport","Gavle","Sweden","GVX","ESSK",60.593299865722656,16.951400756835938,224,1,"E","Europe/Stockholm","airport","OurAirports"
          507,"London Heathrow Airport","London","United Kingdom","LHR","EGLL",51.4706,-0.461941,83,0,"E","Europe/London","airport","OurAirports"
          511,"Brough Airport","Brough","United Kingdom",\N,"EGNB",53.7197,-0.566333,12,0,"E","Europe/London","airport","OurAirports"
          """
        }
    end

    :ok
  end

  doctest OpenFlights

  test "get_airports/1" do
    expected = %{
      full_name: "Gävle Sandviken Airport",
      common_name: "Gävle Sandviken",
      city: "Gavle",
      iata_code: "GVX",
      icao_code: "ESSK",
      timezone: "Europe/Stockholm",
      country: "SE",
      metro_code: nil,
      coordinates: {60.593299865722656, 16.951400756835938}
    }
    assert expected == OpenFlights.get_airports |> Enum.at(0)

    expected = %{
      full_name: "London Heathrow Airport",
      common_name: "London Heathrow",
      city: "London",
      iata_code: "LHR",
      icao_code: "EGLL",
      timezone: "Europe/London",
      country: "GB",
      metro_code: "LON",
      coordinates: {51.4706, -0.461941}
    }
    assert expected == OpenFlights.get_airports |> Enum.at(1)
  end

  test "get_airports/1 replaces `\\N` with `nil`" do
    assert %{iata_code: nil, icao_code: "EGNB"} = OpenFlights.get_airports |> Enum.at(2)
  end
end
