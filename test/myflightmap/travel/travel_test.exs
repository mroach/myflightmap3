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
end
