defmodule Myflightmap.Travel do
  @moduledoc """
  The Travel context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Ecto.Multi
  alias Myflightmap.Repo

  alias Myflightmap.Accounts.User
  alias Myflightmap.Travel.{Flight, Trip}

  @preload_flight_assocs [:depart_airport, :arrive_airport, :airline, :aircraft_type, :trip, :user]

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
  List the trips for the given user as a list that can be used for an option picker
  """
  def list_trip_options(%User{id: user_id}), do: list_trip_options(user_id)
  def list_trip_options(user_id) when is_integer(user_id) do
    query = from t in Trip, where: t.user_id == ^user_id, select: {t.name, t.id}
    Repo.all(query)
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

  def get_trip_with_assocs!(id) do
    id
    |> get_trip!
    |> Repo.preload([:user, flights: @preload_flight_assocs])
  end

  def get_or_create_trip_by_name(%User{} = user, name) when is_binary(name) do
    Trip
    |> where([t], t.user_id == ^user.id and ilike(t.name, ^name))
    |> Repo.one
    |> case do
      %Trip{} = trip ->
        {:ok, trip}
      nil ->
        create_trip(user, %{name: name})
    end
  end

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

  @doc """
  Returns the list of flights.

  ## Examples

      iex> list_flights()
      [%Flight{}, ...]

  """
  def list_flights do
    query = from f in Flight, order_by: [desc: f.depart_date]
    Repo.all(query)
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
  def create_flight(%Flight{} = flight, attrs) when is_map(attrs) do
    insert_or_update_flight(flight, attrs)
  end
  def create_flight(%User{} = user, attrs) when is_map(attrs) do
    %Flight{user: user} |> create_flight(attrs)
  end
  def create_flight(attrs) when is_map(attrs) do
    create_flight(%Flight{}, attrs)
  end

  @doc """
  Updates a flight.

  ## Examples

      iex> update_flight(flight, %{field: new_value})
      {:ok, %Flight{}}

      iex> update_flight(flight, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_flight(flight, attrs), do: insert_or_update_flight(flight, attrs)

  defp insert_or_update_flight(%Flight{} = flight, attrs) do
    changeset =
      flight
      |> preassign_airports(attrs)
      |> Repo.preload([:depart_airport, :arrive_airport])
      |> Flight.changeset(attrs)

    Multi.new
    |> Multi.insert_or_update(:flight, changeset)
    |> Multi.run(:trip_dates, &update_trip_dates/2)
    |> Repo.transaction()
    |> case do
      {:ok, %{flight: flight}} -> {:ok, flight}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def preassign_airports(%Flight{} = flight, attrs) do
    flight
    |> Changeset.cast(attrs, [:depart_airport_id, :arrive_airport_id])
    |> Changeset.apply_changes
  end

  # After adding or updating a flight, re-calculate the start and end dates
  # on the related trip and update the trip
  defp update_trip_dates(repo, %{flight: flight}) do
    with %{trip: %Trip{} = trip} <- Repo.preload(flight, [:trip]),
         {start_date, end_date} <- get_trip_dates(trip)
    do
      trip
      |> Changeset.change(start_date: start_date)
      |> Changeset.change(end_date: end_date)
      |> repo.update
    else
      _ -> {:ok, :noop}
    end
  end

  @doc """
  Fetch the start and end dates of a trip based on the flights' departure and
  arrival dates.
  """
  def get_trip_dates(%Trip{id: trip_id}), do: get_trip_dates(trip_id)
  def get_trip_dates(trip_id) when is_integer(trip_id) do
    query = from f in Flight,
            where: f.trip_id == ^trip_id,
            select: {min(f.depart_date), max(f.arrive_date)}
    Repo.one(query)
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
    Multi.new
    |> Multi.delete(:flight, flight)
    |> Multi.run(:trip_dates, &update_trip_dates/2)
    |> Repo.transaction
    |> case do
      {:ok, %{flight: flight}} -> {:ok, flight}
      {:error, _, changeset, _} -> {:error, changeset}
    end
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
