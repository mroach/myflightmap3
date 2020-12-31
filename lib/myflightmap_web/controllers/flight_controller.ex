defmodule MyflightmapWeb.FlightController do
  use MyflightmapWeb, :controller

  alias Myflightmap.Travel
  alias Myflightmap.Travel.Flight

  def index(conn, _params) do
    flights = Travel.list_flights_with_assocs()
    render(conn, "index.html", flights: flights)
  end

  def new(conn, _params) do
    changeset = Travel.change_flight(%Flight{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"flight" => flight_params}) do
    user = conn.assigns.current_user
    case Travel.create_flight(user, flight_params) do
      {:ok, flight} ->
        conn
        |> put_flash(:info, "Flight created successfully.")
        |> redirect(to: Routes.flight_path(conn, :show, flight))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    flight = Travel.get_flight_with_assocs!(id)
    render(conn, "show.html", flight: flight)
  end

  def edit(conn, %{"id" => id}) do
    flight = Travel.get_flight!(id)
    changeset = Travel.change_flight(flight)
    render(conn, "edit.html", flight: flight, changeset: changeset)
  end

  def update(conn, %{"id" => id, "flight" => flight_params}) do
    flight = Travel.get_flight!(id)

    case Travel.update_flight(flight, flight_params) do
      {:ok, flight} ->
        conn
        |> put_flash(:info, "Flight updated successfully.")
        |> redirect(to: Routes.flight_path(conn, :show, flight))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", flight: flight, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    flight = Travel.get_flight!(id)
    {:ok, _flight} = Travel.delete_flight(flight)

    conn
    |> put_flash(:info, "Flight deleted successfully.")
    |> redirect(to: Routes.flight_path(conn, :index))
  end
end
