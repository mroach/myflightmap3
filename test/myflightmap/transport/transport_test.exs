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

  describe "aircraft" do
    alias Myflightmap.Transport.Aircraft

    @valid_attrs %{engine_count: "some engine_count", engine_type: "some engine_type", iata_code: "some iata_code", icao_code: "some icao_code", manufacturer_code: "some manufacturer_code", model: "some model"}
    @update_attrs %{engine_count: "some updated engine_count", engine_type: "some updated engine_type", iata_code: "some updated iata_code", icao_code: "some updated icao_code", manufacturer_code: "some updated manufacturer_code", model: "some updated model"}
    @invalid_attrs %{engine_count: nil, engine_type: nil, iata_code: nil, icao_code: nil, manufacturer_code: nil, model: nil}

    def aircraft_fixture(attrs \\ %{}) do
      {:ok, aircraft} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Transport.create_aircraft()

      aircraft
    end

    test "list_aircraft/0 returns all aircraft" do
      aircraft = aircraft_fixture()
      assert Transport.list_aircraft() == [aircraft]
    end

    test "get_aircraft!/1 returns the aircraft with given id" do
      aircraft = aircraft_fixture()
      assert Transport.get_aircraft!(aircraft.id) == aircraft
    end

    test "create_aircraft/1 with valid data creates a aircraft" do
      assert {:ok, %Aircraft{} = aircraft} = Transport.create_aircraft(@valid_attrs)
      assert aircraft.engine_count == "some engine_count"
      assert aircraft.engine_type == "some engine_type"
      assert aircraft.iata_code == "some iata_code"
      assert aircraft.icao_code == "some icao_code"
      assert aircraft.manufacturer_code == "some manufacturer_code"
      assert aircraft.model == "some model"
    end

    test "create_aircraft/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transport.create_aircraft(@invalid_attrs)
    end

    test "update_aircraft/2 with valid data updates the aircraft" do
      aircraft = aircraft_fixture()
      assert {:ok, aircraft} = Transport.update_aircraft(aircraft, @update_attrs)
      assert %Aircraft{} = aircraft
      assert aircraft.engine_count == "some updated engine_count"
      assert aircraft.engine_type == "some updated engine_type"
      assert aircraft.iata_code == "some updated iata_code"
      assert aircraft.icao_code == "some updated icao_code"
      assert aircraft.manufacturer_code == "some updated manufacturer_code"
      assert aircraft.model == "some updated model"
    end

    test "update_aircraft/2 with invalid data returns error changeset" do
      aircraft = aircraft_fixture()
      assert {:error, %Ecto.Changeset{}} = Transport.update_aircraft(aircraft, @invalid_attrs)
      assert aircraft == Transport.get_aircraft!(aircraft.id)
    end

    test "delete_aircraft/1 deletes the aircraft" do
      aircraft = aircraft_fixture()
      assert {:ok, %Aircraft{}} = Transport.delete_aircraft(aircraft)
      assert_raise Ecto.NoResultsError, fn -> Transport.get_aircraft!(aircraft.id) end
    end

    test "change_aircraft/1 returns a aircraft changeset" do
      aircraft = aircraft_fixture()
      assert %Ecto.Changeset{} = Transport.change_aircraft(aircraft)
    end
  end
end
