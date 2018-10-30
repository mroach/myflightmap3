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

  describe "aircraft types" do
    alias Myflightmap.Transport.AircraftType

    test "list_aircraft_types/0 returns all aircraft types" do
      aircraft_type = insert(:aircraft_type)
      assert Transport.list_aircraft_types() == [aircraft_type]
    end

    test "get_aircraft_type!/1 returns the aircraft type with given id" do
      aircraft_type = insert(:aircraft_type)
      assert Transport.get_aircraft_type!(aircraft_type.id) == aircraft_type
    end

    test "create_aircraft_type/1 with valid data creates a aircraft type" do
      attrs = params_for(:aircraft_type)
      assert {:ok, %AircraftType{} = aircraft_type} = Transport.create_aircraft_type(attrs)
      assert aircraft_type.engine_count == attrs.engine_count
      assert aircraft_type.engine_type == attrs.engine_type
      assert aircraft_type.iata_code == attrs.iata_code
      assert aircraft_type.icao_code == attrs.icao_code
      assert aircraft_type.manufacturer_code == attrs.manufacturer_code
      assert aircraft_type.description == attrs.description
    end

    test "create_aircraft_type/1 with invalid data returns error changeset" do
      invalid_attrs = params_for(:aircraft_type) |> Map.put(:description, nil)
      assert {:error, %Ecto.Changeset{}} = Transport.create_aircraft_type(invalid_attrs)
    end

    test "update_aircraft_type/2 with valid data updates the aircraft type" do
      aircraft_type = insert(:aircraft_type)
      update_attrs = %{description: "new description"}
      assert {:ok, aircraft_type} = Transport.update_aircraft_type(aircraft_type, update_attrs)
      assert %AircraftType{} = aircraft_type
      assert aircraft_type.description == update_attrs.description
    end

    test "update_aircraft_type/2 with invalid data returns error changeset" do
      aircraft_type = insert(:aircraft_type)
      invalid_attrs = %{description: nil}
      assert {:error, %Ecto.Changeset{}} = Transport.update_aircraft_type(aircraft_type, invalid_attrs)
      assert aircraft_type == Transport.get_aircraft_type!(aircraft_type.id)
    end

    test "delete_aircraft_type/1 deletes the aircraft type" do
      aircraft_type = insert(:aircraft_type)
      assert {:ok, %AircraftType{}} = Transport.delete_aircraft_type(aircraft_type)
      assert_raise Ecto.NoResultsError, fn -> Transport.get_aircraft_type!(aircraft_type.id) end
    end

    test "change_aircraft_type/1 returns a aircraft type changeset" do
      aircraft_type = insert(:aircraft_type)
      assert %Ecto.Changeset{} = Transport.change_aircraft_type(aircraft_type)
    end
  end
end
