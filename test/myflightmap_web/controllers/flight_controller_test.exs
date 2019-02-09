defmodule MyflightmapWeb.FlightControllerTest do
  use MyflightmapWeb.ConnCase

  import Myflightmap.Factory

  @invalid_attrs %{depart_date: nil, depart_airport_id: nil}

  describe "index" do
    test "lists all flights", %{authed_conn: conn} do
      conn = get conn, flight_path(conn, :index)
      assert html_response(conn, 200) =~ "Flights"
    end
  end

  describe "new flight" do
    test "renders form", %{authed_conn: conn} do
      conn = get conn, flight_path(conn, :new)
      assert html_response(conn, 200) =~ "New Flight"
    end
  end

  describe "create flight" do
    test "redirects to show when data is valid", %{authed_conn: conn} do
      params = params_with_assocs(:flight)
      res = post conn, flight_path(conn, :create), flight: params

      assert %{id: id} = redirected_params(res)
      assert redirected_to(res) == flight_path(conn, :show, id)

      res = get conn, flight_path(conn, :show, id)
      assert html_response(res, 200) =~ params.flight_code
    end

    test "renders errors when data is invalid", %{authed_conn: conn} do
      conn = post conn, flight_path(conn, :create), flight: @invalid_attrs
      assert html_response(conn, 200) =~ "New Flight"
    end
  end

  describe "edit flight" do
    setup [:create_flight]

    test "renders form for editing chosen flight", %{authed_conn: conn, flight: flight} do
      conn = get conn, flight_path(conn, :edit, flight)
      assert html_response(conn, 200) =~ "Edit Flight"
    end
  end

  describe "update flight" do
    setup [:create_flight]

    test "redirects when data is valid", %{authed_conn: conn, flight: flight} do
      update_attrs = %{seat: "1B"}
      res = put conn, flight_path(conn, :update, flight), flight: update_attrs
      assert redirected_to(res) == flight_path(conn, :show, flight)

      res = get conn, flight_path(conn, :show, flight)
      assert html_response(res, 200) =~ update_attrs.seat
    end

    test "renders errors when data is invalid", %{authed_conn: conn, flight: flight} do
      res = put conn, flight_path(conn, :update, flight), flight: @invalid_attrs
      assert html_response(res, 200) =~ "Edit Flight"
    end
  end

  describe "delete flight" do
    setup [:create_flight]

    test "deletes chosen flight", %{authed_conn: conn, flight: flight} do
      res = delete conn, flight_path(conn, :delete, flight)
      assert redirected_to(res) == flight_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, flight_path(conn, :show, flight)
      end
    end
  end

  defp create_flight(_) do
    flight = insert(:flight)
    {:ok, flight: flight}
  end
end
