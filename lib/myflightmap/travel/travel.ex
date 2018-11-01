defmodule Myflightmap.Travel do
  @moduledoc """
  The Travel context.
  """

  import Ecto.Query, warn: false
  alias Myflightmap.Repo

  alias Myflightmap.Travel.Trip
  alias Myflightmap.Accounts.User

  @doc """
  Returns the list of trips with the `user` preloaded.

  ## Examples

      iex> list_trips()
      [%Trip{}, ...]

  """
  def list_trips do
    Trip
    |> Repo.all
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single trip with the `user` preloaded.

  Raises `Ecto.NoResultsError` if the Trip does not exist.

  ## Examples

      iex> get_trip!(123)
      %Trip{}

      iex> get_trip!(456)
      ** (Ecto.NoResultsError)

  """
  def get_trip!(id), do: Trip |> Repo.get!(id) |> Repo.preload(:user)

  @doc """
  Creates a trip for the given user.

  ## Examples

      iex> create_trip(user, %{field: value})
      {:ok, %Trip{}}

      iex> create_trip(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_trip(user, attrs \\ %{}) do
    %Trip{user: user}
    |> Trip.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a trip.

  ## Examples

      iex> update_trip(trip, %{field: new_value})
      {:ok, %Trip{}}

      iex> update_trip(trip, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_trip(%Trip{} = trip, attrs) do
    trip
    |> Trip.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Trip.

  ## Examples

      iex> delete_trip(trip)
      {:ok, %Trip{}}

      iex> delete_trip(trip)
      {:error, %Ecto.Changeset{}}

  """
  def delete_trip(%Trip{} = trip) do
    Repo.delete(trip)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking trip changes.

  ## Examples

      iex> change_trip(trip)
      %Ecto.Changeset{source: %Trip{}}

  """
  def change_trip(%Trip{} = trip) do
    Trip.changeset(trip, %{})
  end

  alias Myflightmap.Travel.Flight

  @preload_flight_assocs [:depart_airport, :arrive_airport, :airline, :aircraft_type, :trip, :user]

  @doc """
  Returns the list of flights.

  ## Examples

      iex> list_flights()
      [%Flight{}, ...]

  """
  def list_flights do
    from(f in Flight, order_by: [desc: f.depart_date])
    |> Repo.all
  end

  def list_flights_with_assocs do
    list_flights()
    |> Repo.preload(@preload_flight_assocs)
  end

  @doc """
  Gets a single flight.

  Raises `Ecto.NoResultsError` if the Flight does not exist.

  ## Examples

      iex> get_flight!(123)
      %Flight{}

      iex> get_flight!(456)
      ** (Ecto.NoResultsError)

  """
  def get_flight!(id), do: Flight |> Repo.get!(id)

  def get_flight_with_assocs!(id) do
    id
    |> get_flight!()
    |> Repo.preload(@preload_flight_assocs)
  end

  @doc """
  Creates a flight.

  ## Examples

      iex> create_flight(user, %{field: value})
      {:ok, %Flight{}}

      iex> create_flight(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_flight(%User{} = user, attrs \\ %{}) do
    %Flight{user: user}
    |> Flight.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a flight.

  ## Examples

      iex> update_flight(flight, %{field: new_value})
      {:ok, %Flight{}}

      iex> update_flight(flight, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_flight(%Flight{} = flight, attrs) do
    flight
    |> Flight.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Flight.

  ## Examples

      iex> delete_flight(flight)
      {:ok, %Flight{}}

      iex> delete_flight(flight)
      {:error, %Ecto.Changeset{}}

  """
  def delete_flight(%Flight{} = flight) do
    Repo.delete(flight)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking flight changes.

  ## Examples

      iex> change_flight(flight)
      %Ecto.Changeset{source: %Flight{}}

  """
  def change_flight(%Flight{} = flight) do
    Flight.changeset(flight, %{})
  end
end
