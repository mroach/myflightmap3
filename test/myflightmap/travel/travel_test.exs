defmodule Myflightmap.TravelTest do
  use Myflightmap.DataCase

  alias Myflightmap.Travel
  import Myflightmap.Factory

  describe "trips" do
    alias Myflightmap.Travel.Trip

    @invalid_attrs %{name: nil, privacy: nil, purpose: nil, start_date: nil}

    test "list_trips/0 returns all trips" do
      trip = insert(:trip)
      assert Travel.list_trips() == [trip]
    end

    test "get_trip!/1 returns the trip with given id" do
      trip = insert(:trip)
      assert Travel.get_trip!(trip.id) == trip
    end

    test "create_trip/1 with valid data creates a trip" do
      user = insert(:user)
      assert {:ok, %Trip{} = trip} = Travel.create_trip(user, params_for(:trip))
    end

    test "create_trip/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Travel.create_trip(@invalid_attrs)
    end

    test "update_trip/2 with valid data updates the trip" do
      trip = insert(:trip)
      update_attrs = %{name: "new name"}
      assert {:ok, trip} = Travel.update_trip(trip, update_attrs)
      assert %Trip{} = trip
      assert trip.name == "new name"
    end

    test "update_trip/2 with invalid data returns error changeset" do
      trip = insert(:trip)
      assert {:error, %Ecto.Changeset{}} = Travel.update_trip(trip, @invalid_attrs)
      assert trip == Travel.get_trip!(trip.id)
    end

    test "delete_trip/1 deletes the trip" do
      trip = insert(:trip)
      assert {:ok, %Trip{}} = Travel.delete_trip(trip)
      assert_raise Ecto.NoResultsError, fn -> Travel.get_trip!(trip.id) end
    end

    test "change_trip/1 returns a trip changeset" do
      trip = insert(:trip)
      assert %Ecto.Changeset{} = Travel.change_trip(trip)
    end
  end

  describe "flights" do
    alias Myflightmap.Travel.Flight

    @valid_attrs %{aircraft_registration: "some aircraft_registration", arrive_date: ~D[2010-04-17], arrive_time: ~T[14:00:00.000000], confirmation_number: "some confirmation_number", depart_date: ~D[2010-04-17], depart_time: ~T[14:00:00.000000], distance: 42, duration: 42, flight_code: "some flight_code", seat: "some seat", seat_class: "some seat_class"}
    @update_attrs %{aircraft_registration: "some updated aircraft_registration", arrive_date: ~D[2011-05-18], arrive_time: ~T[15:01:01.000000], confirmation_number: "some updated confirmation_number", depart_date: ~D[2011-05-18], depart_time: ~T[15:01:01.000000], distance: 43, duration: 43, flight_code: "some updated flight_code", seat: "some updated seat", seat_class: "some updated seat_class"}
    @invalid_attrs %{aircraft_registration: nil, arrive_date: nil, arrive_time: nil, confirmation_number: nil, depart_date: nil, depart_time: nil, distance: nil, duration: nil, flight_code: nil, seat: nil, seat_class: nil}

    def flight_fixture(attrs \\ %{}) do
      {:ok, flight} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Travel.create_flight()

      flight
    end

    test "list_flights/0 returns all flights" do
      flight = flight_fixture()
      assert Travel.list_flights() == [flight]
    end

    test "get_flight!/1 returns the flight with given id" do
      flight = flight_fixture()
      assert Travel.get_flight!(flight.id) == flight
    end

    test "create_flight/1 with valid data creates a flight" do
      assert {:ok, %Flight{} = flight} = Travel.create_flight(@valid_attrs)
      assert flight.aircraft_registration == "some aircraft_registration"
      assert flight.arrive_date == ~D[2010-04-17]
      assert flight.arrive_time == ~T[14:00:00.000000]
      assert flight.confirmation_number == "some confirmation_number"
      assert flight.depart_date == ~D[2010-04-17]
      assert flight.depart_time == ~T[14:00:00.000000]
      assert flight.distance == 42
      assert flight.duration == 42
      assert flight.flight_code == "some flight_code"
      assert flight.seat == "some seat"
      assert flight.seat_class == "some seat_class"
    end

    test "create_flight/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Travel.create_flight(@invalid_attrs)
    end

    test "update_flight/2 with valid data updates the flight" do
      flight = flight_fixture()
      assert {:ok, flight} = Travel.update_flight(flight, @update_attrs)
      assert %Flight{} = flight
      assert flight.aircraft_registration == "some updated aircraft_registration"
      assert flight.arrive_date == ~D[2011-05-18]
      assert flight.arrive_time == ~T[15:01:01.000000]
      assert flight.confirmation_number == "some updated confirmation_number"
      assert flight.depart_date == ~D[2011-05-18]
      assert flight.depart_time == ~T[15:01:01.000000]
      assert flight.distance == 43
      assert flight.duration == 43
      assert flight.flight_code == "some updated flight_code"
      assert flight.seat == "some updated seat"
      assert flight.seat_class == "some updated seat_class"
    end

    test "update_flight/2 with invalid data returns error changeset" do
      flight = flight_fixture()
      assert {:error, %Ecto.Changeset{}} = Travel.update_flight(flight, @invalid_attrs)
      assert flight == Travel.get_flight!(flight.id)
    end

    test "delete_flight/1 deletes the flight" do
      flight = flight_fixture()
      assert {:ok, %Flight{}} = Travel.delete_flight(flight)
      assert_raise Ecto.NoResultsError, fn -> Travel.get_flight!(flight.id) end
    end

    test "change_flight/1 returns a flight changeset" do
      flight = flight_fixture()
      assert %Ecto.Changeset{} = Travel.change_flight(flight)
    end
  end
end
