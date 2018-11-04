defmodule Myflightmap.FlightDurationTest do
  use ExUnit.Case
  use Myflightmap.DataCase

  import Myflightmap.Factory

  alias Myflightmap.FlightDuration
  alias Myflightmap.Travel.Flight

  doctest Myflightmap.FlightDuration

  test "movement_time/2 returns full zone-aware datetime" do
    changeset = Flight.changeset(%Flight{}, params_with_assocs(:flight))

    result = FlightDuration.movement_time(changeset, "depart")
    assert is_nil(result) == false
  end

  test "from_changeset/1 calculates duration for airports in the same timezone" do
    dap = insert(:airport)
    aap = insert(:airport, timezone: dap.timezone)

    flight_time_minutes = 140

    params = params_with_assocs(:flight, depart_airport: dap, arrive_airport: aap)
    params =
      params
      |> Map.put(:arrive_date, params.depart_date)
      |> Map.put(:arrive_time, Time.add(params.depart_time, flight_time_minutes * 60))

    changeset = Flight.changeset(%Flight{}, params)

    assert FlightDuration.from_changeset(changeset) == flight_time_minutes
  end

  test "from_changeset/1 calculates duration for airports in the different timezones" do
    dap = insert(:airport, timezone: "Asia/Singapore")
    aap = insert(:airport, timezone: "Asia/Tokyo")

    flight_time_minutes = 140

    params = params_with_assocs(:flight, depart_airport: dap, arrive_airport: aap)
    # We add 60 minutes to the arrive time because Tokyo is an hour ahead of Singapore
    params =
      params
      |> Map.put(:arrive_date, params.depart_date)
      |> Map.put(:arrive_time, Time.add(params.depart_time, (flight_time_minutes + 60) * 60))

    changeset = Flight.changeset(%Flight{}, params)

    assert flight_time_minutes = FlightDuration.from_changeset(changeset)
  end

  test "from_changeset/1 when arrival time is missing" do
    changeset = Flight.changeset(%Flight{}, params_with_assocs(:flight, arrive_time: nil))

    assert nil == FlightDuration.from_changeset(changeset)
  end
end
