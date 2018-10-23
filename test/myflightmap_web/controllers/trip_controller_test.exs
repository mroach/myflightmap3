defmodule MyflightmapWeb.TripControllerTest do
  use MyflightmapWeb.ConnCase

  import Myflightmap.Factory

  @invalid_attrs %{end_date: nil, name: nil, privacy: nil, purpose: nil, start_date: nil}

  describe "index" do
    test "lists all trips", %{conn: conn} do
      conn = get conn, trip_path(conn, :index)
      assert html_response(conn, 200) =~ "Trips"
    end
  end

  describe "new trip" do
    test "renders form", %{conn: conn} do
      conn = get conn, trip_path(conn, :new)
      assert html_response(conn, 200) =~ "New Trip"
    end
  end

  describe "create trip" do
    test "redirects to show when data is valid", %{conn: conn} do
      params = params_for(:trip)
      conn = post conn, trip_path(conn, :create), trip: params

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == trip_path(conn, :show, id)

      conn = get conn, trip_path(conn, :show, id)
      assert html_response(conn, 200) =~ params.name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, trip_path(conn, :create), trip: @invalid_attrs
      assert html_response(conn, 200) =~ "New Trip"
    end
  end

  describe "edit trip" do
    setup [:create_trip]

    test "renders form for editing chosen trip", %{conn: conn, trip: trip} do
      conn = get conn, trip_path(conn, :edit, trip)
      assert html_response(conn, 200) =~ "Edit Trip"
    end
  end

  describe "update trip" do
    setup [:create_trip]

    test "redirects when data is valid", %{conn: conn, trip: trip} do
      update_attrs = %{name: "new name"}
      conn = put conn, trip_path(conn, :update, trip), trip: update_attrs
      assert redirected_to(conn) == trip_path(conn, :show, trip)

      conn = get conn, trip_path(conn, :show, trip)
      assert html_response(conn, 200) =~ update_attrs.name
    end

    test "renders errors when data is invalid", %{conn: conn, trip: trip} do
      conn = put conn, trip_path(conn, :update, trip), trip: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Trip"
    end
  end

  describe "delete trip" do
    setup [:create_trip]

    test "deletes chosen trip", %{conn: conn, trip: trip} do
      conn = delete conn, trip_path(conn, :delete, trip)
      assert redirected_to(conn) == trip_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, trip_path(conn, :show, trip)
      end
    end
  end

  defp create_trip(_) do
    trip = insert(:trip)
    {:ok, trip: trip}
  end
end