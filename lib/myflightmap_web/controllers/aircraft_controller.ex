defmodule MyflightmapWeb.AircraftController do
  use MyflightmapWeb, :controller

  alias Myflightmap.Transport
  alias Myflightmap.Transport.Aircraft

  def index(conn, _params) do
    aircraft = Transport.list_aircraft()
    render(conn, "index.html", aircraft: aircraft)
  end

  def new(conn, _params) do
    changeset = Transport.change_aircraft(%Aircraft{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"aircraft" => aircraft_params}) do
    case Transport.create_aircraft(aircraft_params) do
      {:ok, aircraft} ->
        conn
        |> put_flash(:info, "Aircraft created successfully.")
        |> redirect(to: aircraft_path(conn, :show, aircraft))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    aircraft = Transport.get_aircraft!(id)
    render(conn, "show.html", aircraft: aircraft)
  end

  def edit(conn, %{"id" => id}) do
    aircraft = Transport.get_aircraft!(id)
    changeset = Transport.change_aircraft(aircraft)
    render(conn, "edit.html", aircraft: aircraft, changeset: changeset)
  end

  def update(conn, %{"id" => id, "aircraft" => aircraft_params}) do
    aircraft = Transport.get_aircraft!(id)

    case Transport.update_aircraft(aircraft, aircraft_params) do
      {:ok, aircraft} ->
        conn
        |> put_flash(:info, "Aircraft updated successfully.")
        |> redirect(to: aircraft_path(conn, :show, aircraft))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", aircraft: aircraft, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    aircraft = Transport.get_aircraft!(id)
    {:ok, _aircraft} = Transport.delete_aircraft(aircraft)

    conn
    |> put_flash(:info, "Aircraft deleted successfully.")
    |> redirect(to: aircraft_path(conn, :index))
  end
end
