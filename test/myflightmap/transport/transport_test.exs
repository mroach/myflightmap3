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
end
