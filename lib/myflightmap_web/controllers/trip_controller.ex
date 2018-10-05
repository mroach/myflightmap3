defmodule MyflightmapWeb.TripController do
  use MyflightmapWeb, :controller

  alias Myflightmap.Travel
  alias Myflightmap.Travel.Trip

  def index(conn, _params) do
    trips = Travel.list_trips()
    render(conn, "index.html", trips: trips)
  end

  def new(conn, _params) do
    changeset = Travel.change_trip(%Trip{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"trip" => trip_params}) do
    user = conn.assigns.current_user
    case Travel.create_trip(user, trip_params) do
      {:ok, trip} ->
        conn
        |> put_flash(:info, "Trip created successfully.")
        |> redirect(to: trip_path(conn, :show, trip))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    trip = Travel.get_trip!(id)
    render(conn, "show.html", trip: trip)
  end

  def edit(conn, %{"id" => id}) do
    trip = Travel.get_trip!(id)
    changeset = Travel.change_trip(trip)
    render(conn, "edit.html", trip: trip, changeset: changeset)
  end

  def update(conn, %{"id" => id, "trip" => trip_params}) do
    trip = Travel.get_trip!(id)

    case Travel.update_trip(trip, trip_params) do
      {:ok, trip} ->
        conn
        |> put_flash(:info, "Trip updated successfully.")
        |> redirect(to: trip_path(conn, :show, trip))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", trip: trip, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    trip = Travel.get_trip!(id)
    {:ok, _trip} = Travel.delete_trip(trip)

    conn
    |> put_flash(:info, "Trip deleted successfully.")
    |> redirect(to: trip_path(conn, :index))
  end
end
