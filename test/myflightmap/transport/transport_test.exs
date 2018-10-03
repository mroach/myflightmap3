defmodule Myflightmap.TransportTest do
  use Myflightmap.DataCase

  alias Myflightmap.Transport

  import Myflightmap.Factory

  describe "airlines" do
    alias Myflightmap.Transport.Airline

    @invalid_attrs %{country: "x", iata_code: "0", icao_code: "y", name: nil}

    test "list_airlines/0 returns all airlines" do
      airline = insert(:airline)
      assert Transport.list_airlines() == [airline]
    end

    test "get_airline!/1 returns the airline with given id" do
      airline = insert(:airline)
      assert Transport.get_airline!(airline.id) == airline
    end

    test "create_airline/1 with valid data creates a airline" do
      assert {:ok, %Airline{} = airline} = Transport.create_airline(params_for(:airline))
    end

    test "create_airline/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transport.create_airline(@invalid_attrs)
    end

    test "update_airline/2 with valid data updates the airline" do
      update_attrs = %{alliance: "oneworld", country: "AR"}

      airline = insert(:airline)
      assert {:ok, airline} = Transport.update_airline(airline, update_attrs)
      assert %Airline{} = airline
      assert airline.alliance == update_attrs.alliance
      assert airline.country == update_attrs.country
    end

    test "update_airline/2 with invalid data returns error changeset" do
      airline = insert(:airline)
      assert {:error, %Ecto.Changeset{errors: errors}} = Transport.update_airline(airline, @invalid_attrs)
      assert airline == Transport.get_airline!(airline.id)

      assert {"is invalid", [validation: :inclusion]} = Keyword.get(errors, :country)
      assert {"has invalid format", [validation: :format]} = Keyword.get(errors, :icao_code)
      assert {"has invalid format", [validation: :format]} = Keyword.get(errors, :iata_code)
      assert {"can't be blank", [validation: :required]} = Keyword.get(errors, :name)
    end

    test "delete_airline/1 deletes the airline" do
      airline = insert(:airline)
      assert {:ok, %Airline{}} = Transport.delete_airline(airline)
      assert_raise Ecto.NoResultsError, fn -> Transport.get_airline!(airline.id) end
    end

    test "change_airline/1 returns a airline changeset" do
      airline = insert(:airline)
      assert %Ecto.Changeset{} = Transport.change_airline(airline)
    end
  end

  describe "airports" do
    alias Myflightmap.Transport.Airport

    @invalid_attrs %{city: nil, common_name: nil, coordinates: nil, country: nil}

    test "list_airports/0 returns all airports" do
      airport = insert(:airport)
      assert Transport.list_airports() == [airport]
    end

    test "get_airport!/1 returns the airport with given id" do
      airport = insert(:airport)
      assert Transport.get_airport!(airport.id) == airport
    end

    test "create_airport/1 with valid data creates a airport" do
      assert {:ok, %Airport{} = airport} = Transport.create_airport(params_for(:airport))
    end

    test "create_airport/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transport.create_airport(@invalid_attrs)
    end

    test "update_airport/2 with valid data updates the airport" do
      airport = insert(:airport)
      new_coords = coordinates()
      update_attrs = %{
        coordinates: new_coords,
        full_name: "Tycho"
      }
      assert {:ok, airport} = Transport.update_airport(airport, update_attrs)
      assert %Airport{} = airport
      assert airport.coordinates == new_coords
      assert airport.full_name == "Tycho"
    end

    test "update_airport/2 with invalid data returns error changeset" do
      airport = insert(:airport)
      assert {:error, %Ecto.Changeset{}} = Transport.update_airport(airport, @invalid_attrs)
      assert airport == Transport.get_airport!(airport.id)
    end

    test "delete_airport/1 deletes the airport" do
      airport = insert(:airport)
      assert {:ok, %Airport{}} = Transport.delete_airport(airport)
      assert_raise Ecto.NoResultsError, fn -> Transport.get_airport!(airport.id) end
    end

    test "change_airport/1 returns a airport changeset" do
      airport = insert(:airport)
      assert %Ecto.Changeset{} = Transport.change_airport(airport)
    end
  end
end
