defmodule MyflightmapWeb.AircraftTypeControllerTest do
  use MyflightmapWeb.ConnCase

  import Myflightmap.Factory

  describe "index" do
    test "lists all aircraft_type", %{conn: conn} do
      conn = get(conn, Routes.aircraft_type_path(conn, :index))
      assert html_response(conn, 200) =~ "Aircraft Types"
    end
  end

  describe "new aircraft_type" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.aircraft_type_path(conn, :new))
      assert html_response(conn, 200) =~ "New Aircraft Type"
    end
  end

  describe "create aircraft_type" do
    test "redirects to show when data is valid", %{conn: conn} do
      aircraft_type_params = params_for(:aircraft_type)

      conn =
        post conn, Routes.aircraft_type_path(conn, :create), aircraft_type: aircraft_type_params

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.aircraft_type_path(conn, :show, id)

      conn = get(conn, Routes.aircraft_type_path(conn, :show, id))
      assert html_response(conn, 200) =~ aircraft_type_params.description
    end

    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs = %{description: nil}
      conn = post conn, Routes.aircraft_type_path(conn, :create), aircraft_type: invalid_attrs
      assert html_response(conn, 200) =~ "New Aircraft Type"
    end
  end

  describe "edit aircraft_type" do
    setup [:create_aircraft_type]

    test "renders form for editing chosen aircraft_type", %{
      conn: conn,
      aircraft_type: aircraft_type
    } do
      conn = get(conn, Routes.aircraft_type_path(conn, :edit, aircraft_type))
      assert html_response(conn, 200) =~ "Edit Aircraft Type"
    end
  end

  describe "update aircraft_type" do
    setup [:create_aircraft_type]

    test "redirects when data is valid", %{conn: conn, aircraft_type: aircraft_type} do
      update_attrs = %{description: "new name"}

      conn =
        put conn, Routes.aircraft_type_path(conn, :update, aircraft_type),
          aircraft_type: update_attrs

      assert redirected_to(conn) == Routes.aircraft_type_path(conn, :show, aircraft_type)

      conn = get(conn, Routes.aircraft_type_path(conn, :show, aircraft_type))
      assert html_response(conn, 200) =~ update_attrs.description
    end

    test "renders errors when data is invalid", %{conn: conn, aircraft_type: aircraft_type} do
      invalid_attrs = %{description: nil}

      conn =
        put conn, Routes.aircraft_type_path(conn, :update, aircraft_type),
          aircraft_type: invalid_attrs

      assert html_response(conn, 200) =~ "Edit Aircraft Type"
    end
  end

  describe "delete aircraft_type" do
    setup [:create_aircraft_type]

    test "deletes chosen aircraft_type", %{conn: conn, aircraft_type: aircraft_type} do
      conn = delete(conn, Routes.aircraft_type_path(conn, :delete, aircraft_type))
      assert redirected_to(conn) == Routes.aircraft_type_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.aircraft_type_path(conn, :show, aircraft_type))
      end
    end
  end

  defp create_aircraft_type(_) do
    aircraft_type = insert(:aircraft_type)
    {:ok, aircraft_type: aircraft_type}
  end
end
