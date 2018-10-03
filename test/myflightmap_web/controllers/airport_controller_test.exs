defmodule MyflightmapWeb.AirportControllerTest do
  use MyflightmapWeb.ConnCase

  import Myflightmap.Factory

  @invalid_attrs %{city: nil, common_name: nil, coordinates: nil, country: nil, timezone: nil}

  describe "index" do
    setup [:create_airport]
    test "lists all airports", %{conn: conn} do
      conn = get conn, airport_path(conn, :index)
      assert html_response(conn, 200) =~ "Airports"
    end
  end

  describe "new airport" do
    test "renders form", %{conn: conn} do
      conn = get conn, airport_path(conn, :new)
      assert html_response(conn, 200) =~ "New Airport"
    end
  end

  describe "create airport" do
    test "redirects to show when data is valid", %{conn: conn} do
      params = params_for(:airport)
      conn = post conn, airport_path(conn, :create), airport: params

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == airport_path(conn, :show, id)

      conn = get conn, airport_path(conn, :show, id)
      assert html_response(conn, 200) =~ params.common_name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, airport_path(conn, :create), airport: @invalid_attrs
      assert html_response(conn, 200) =~ "New Airport"
    end
  end

  describe "edit airport" do
    setup [:create_airport]

    test "renders form for editing chosen airport", %{conn: conn, airport: airport} do
      conn = get conn, airport_path(conn, :edit, airport)
      assert html_response(conn, 200) =~ "Edit"
    end
  end

  describe "update airport" do
    setup [:create_airport]

    test "redirects when data is valid", %{conn: conn, airport: airport} do
      update_attrs = %{common_name: "New name"}
      conn = put conn, airport_path(conn, :update, airport), airport: update_attrs
      assert redirected_to(conn) == airport_path(conn, :show, airport)

      conn = get conn, airport_path(conn, :show, airport)
      assert html_response(conn, 200) =~ update_attrs.common_name
    end

    test "renders errors when data is invalid", %{conn: conn, airport: airport} do
      conn = put conn, airport_path(conn, :update, airport), airport: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit"
    end
  end

  describe "delete airport" do
    setup [:create_airport]

    test "deletes chosen airport", %{conn: conn, airport: airport} do
      conn = delete conn, airport_path(conn, :delete, airport)
      assert redirected_to(conn) == airport_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, airport_path(conn, :show, airport)
      end
    end
  end

  defp create_airport(_) do
    {:ok, airport: insert(:airport)}
  end
end
