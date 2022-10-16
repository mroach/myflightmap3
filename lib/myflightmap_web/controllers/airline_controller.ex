defmodule MyflightmapWeb.AirlineController do
  use MyflightmapWeb, :controller

  alias Myflightmap.Transport
  alias Myflightmap.Transport.Airline

  def index(conn, _params) do
    airlines = Transport.list_airlines()
    render(conn, "index.html", airlines: airlines)
  end

  def new(conn, _params) do
    changeset = Transport.change_airline(%Airline{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"airline" => airline_params}) do
    case Transport.create_airline(airline_params) do
      {:ok, airline} ->
        conn
        |> put_flash(:info, "Airline created successfully.")
        |> redirect(to: Routes.airline_path(conn, :show, airline))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    airline = Transport.get_airline!(id)
    render(conn, "show.html", airline: airline)
  end

  def edit(conn, %{"id" => id}) do
    airline = Transport.get_airline!(id)
    changeset = Transport.change_airline(airline)
    render(conn, "edit.html", airline: airline, changeset: changeset)
  end

  def update(conn, %{"id" => id, "airline" => airline_params}) do
    airline = Transport.get_airline!(id)

    case Transport.update_airline(airline, airline_params) do
      {:ok, airline} ->
        conn
        |> put_flash(:info, "Airline updated successfully.")
        |> redirect(to: Routes.airline_path(conn, :show, airline))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", airline: airline, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    airline = Transport.get_airline!(id)
    {:ok, _airline} = Transport.delete_airline(airline)

    conn
    |> put_flash(:info, "Airline deleted successfully.")
    |> redirect(to: Routes.airline_path(conn, :index))
  end
end
