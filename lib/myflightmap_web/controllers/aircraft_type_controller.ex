defmodule MyflightmapWeb.AircraftTypeController do
  use MyflightmapWeb, :controller

  alias Myflightmap.Transport
  alias Myflightmap.Transport.AircraftType

  def index(conn, _params) do
    aircraft_types = Transport.list_aircraft_types()
    render(conn, "index.html", aircraft_types: aircraft_types)
  end

  def new(conn, _params) do
    changeset = Transport.change_aircraft_type(%AircraftType{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"aircraft_type" => aircraft_type_params}) do
    case Transport.create_aircraft_type(aircraft_type_params) do
      {:ok, aircraft_type} ->
        conn
        |> put_flash(:info, "Aircraft type created successfully.")
        |> redirect(to: Routes.aircraft_type_path(conn, :show, aircraft_type))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    aircraft_type = Transport.get_aircraft_type!(id)
    render(conn, "show.html", aircraft_type: aircraft_type)
  end

  def edit(conn, %{"id" => id}) do
    aircraft_type = Transport.get_aircraft_type!(id)
    changeset = Transport.change_aircraft_type(aircraft_type)
    render(conn, "edit.html", aircraft_type: aircraft_type, changeset: changeset)
  end

  def update(conn, %{"id" => id, "aircraft_type" => aircraft_type_params}) do
    aircraft_type = Transport.get_aircraft_type!(id)

    case Transport.update_aircraft_type(aircraft_type, aircraft_type_params) do
      {:ok, aircraft_type} ->
        conn
        |> put_flash(:info, "Aircraft type updated successfully.")
        |> redirect(to: Routes.aircraft_type_path(conn, :show, aircraft_type))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", aircraft_type: aircraft_type, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    aircraft_type = Transport.get_aircraft_type!(id)
    {:ok, _aircraft_type} = Transport.delete_aircraft_type(aircraft_type)

    conn
    |> put_flash(:info, "Aircraft type deleted successfully.")
    |> redirect(to: Routes.aircraft_type_path(conn, :index))
  end
end
