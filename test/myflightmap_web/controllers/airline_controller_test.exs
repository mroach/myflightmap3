defmodule MyflightmapWeb.AirlineControllerTest do
  use MyflightmapWeb.ConnCase

  import Myflightmap.Factory

  describe "index" do
    test "lists all airlines", %{conn: conn} do
      insert_list(2, :airline)
      conn = get conn, airline_path(conn, :index)
      assert html_response(conn, 200) =~ "Airlines"
    end
  end

  describe "new airline" do
    test "renders form", %{conn: conn} do
      conn = get conn, airline_path(conn, :new)
      assert html_response(conn, 200) =~ "New Airline"
    end
  end

  describe "create airline" do
    test "redirects to show when data is valid", %{conn: conn} do
      airline_params = params_for(:airline)

      conn = post conn, airline_path(conn, :create), airline: airline_params

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == airline_path(conn, :show, id)

      conn = get conn, airline_path(conn, :show, id)
      assert html_response(conn, 200) =~ airline_params.name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs = %{name: nil, iata_code: "z"}

      conn = post conn, airline_path(conn, :create), airline: invalid_attrs
      assert html_response(conn, 200) =~ "New Airline"
    end
  end

  describe "edit airline" do
    setup [:create_airline]

    test "renders form for editing chosen airline", %{conn: conn, airline: airline} do
      conn = get conn, airline_path(conn, :edit, airline)
      assert html_response(conn, 200) =~ "Edit Airline"
    end
  end

  describe "update airline" do
    setup [:create_airline]

    test "redirects when data is valid", %{conn: conn, airline: airline} do
      update_attrs = %{name: "XYZ Air"}

      conn = put conn, airline_path(conn, :update, airline), airline: update_attrs
      assert redirected_to(conn) == airline_path(conn, :show, airline)

      conn = get conn, airline_path(conn, :show, airline)
      assert html_response(conn, 200) =~ update_attrs.name
    end

    test "renders errors when data is invalid", %{conn: conn, airline: airline} do
      invalid_attrs = %{name: nil, iata_code: "z"}

      conn = put conn, airline_path(conn, :update, airline), airline: invalid_attrs
      assert html_response(conn, 200) =~ "Edit Airline"
    end
  end

  describe "delete airline" do
    setup [:create_airline]

    test "deletes chosen airline", %{conn: conn, airline: airline} do
      conn = delete conn, airline_path(conn, :delete, airline)
      assert redirected_to(conn) == airline_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, airline_path(conn, :show, airline)
      end
    end
  end

  defp create_airline(_) do
    airline = insert(:airline)
    {:ok, airline: airline}
  end
end
