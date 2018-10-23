defmodule Myflightmap.Travel do
  @moduledoc """
  The Travel context.
  """

  import Ecto.Query, warn: false
  alias Myflightmap.Repo

  alias Myflightmap.Travel.Trip

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
end