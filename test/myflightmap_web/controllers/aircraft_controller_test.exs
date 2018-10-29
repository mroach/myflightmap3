defmodule MyflightmapWeb.AircraftControllerTest do
  use MyflightmapWeb.ConnCase

  alias Myflightmap.Transport

  @create_attrs %{engine_count: "some engine_count", engine_type: "some engine_type", iata_code: "some iata_code", icao_code: "some icao_code", manufacturer_code: "some manufacturer_code", model: "some model"}
  @update_attrs %{engine_count: "some updated engine_count", engine_type: "some updated engine_type", iata_code: "some updated iata_code", icao_code: "some updated icao_code", manufacturer_code: "some updated manufacturer_code", model: "some updated model"}
  @invalid_attrs %{engine_count: nil, engine_type: nil, iata_code: nil, icao_code: nil, manufacturer_code: nil, model: nil}

  def fixture(:aircraft) do
    {:ok, aircraft} = Transport.create_aircraft(@create_attrs)
    aircraft
  end

  describe "index" do
    test "lists all aircraft", %{conn: conn} do
      conn = get conn, aircraft_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Aircraft"
    end
  end

  describe "new aircraft" do
    test "renders form", %{conn: conn} do
      conn = get conn, aircraft_path(conn, :new)
      assert html_response(conn, 200) =~ "New Aircraft"
    end
  end

  describe "create aircraft" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, aircraft_path(conn, :create), aircraft: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == aircraft_path(conn, :show, id)

      conn = get conn, aircraft_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Aircraft"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, aircraft_path(conn, :create), aircraft: @invalid_attrs
      assert html_response(conn, 200) =~ "New Aircraft"
    end
  end

  describe "edit aircraft" do
    setup [:create_aircraft]

    test "renders form for editing chosen aircraft", %{conn: conn, aircraft: aircraft} do
      conn = get conn, aircraft_path(conn, :edit, aircraft)
      assert html_response(conn, 200) =~ "Edit Aircraft"
    end
  end

  describe "update aircraft" do
    setup [:create_aircraft]

    test "redirects when data is valid", %{conn: conn, aircraft: aircraft} do
      conn = put conn, aircraft_path(conn, :update, aircraft), aircraft: @update_attrs
      assert redirected_to(conn) == aircraft_path(conn, :show, aircraft)

      conn = get conn, aircraft_path(conn, :show, aircraft)
      assert html_response(conn, 200) =~ "some updated engine_count"
    end

    test "renders errors when data is invalid", %{conn: conn, aircraft: aircraft} do
      conn = put conn, aircraft_path(conn, :update, aircraft), aircraft: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Aircraft"
    end
  end

  describe "delete aircraft" do
    setup [:create_aircraft]

    test "deletes chosen aircraft", %{conn: conn, aircraft: aircraft} do
      conn = delete conn, aircraft_path(conn, :delete, aircraft)
      assert redirected_to(conn) == aircraft_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, aircraft_path(conn, :show, aircraft)
      end
    end
  end

  defp create_aircraft(_) do
    aircraft = fixture(:aircraft)
    {:ok, aircraft: aircraft}
  end
end
