defmodule Myflightmap.Transport do
  @moduledoc """
  The Transport context.
  """

  import Ecto.Query, warn: false
  alias Myflightmap.Repo
  alias Myflightmap.Transport.Airline

  @doc """
  Returns the list of airlines.

  ## Examples

      iex> list_airlines()
      [%Airline{}, ...]

  """
  def list_airlines do
    Airline
    |> order_by(:name)
    |> Repo.all
  end

  @doc """
  Gets a single airline.

  Raises `Ecto.NoResultsError` if the Airline does not exist.

  ## Examples

      iex> get_airline!(123)
      %Airline{}

      iex> get_airline!(456)
      ** (Ecto.NoResultsError)

  """
  def get_airline!(id), do: Repo.get!(Airline, id)

  @doc """
  Creates a airline.

  ## Examples

      iex> create_airline(%{field: value})
      {:ok, %Airline{}}

      iex> create_airline(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_airline(attrs \\ %{}) do
    %Airline{}
    |> Airline.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a airline.

  ## Examples

      iex> update_airline(airline, %{field: new_value})
      {:ok, %Airline{}}

      iex> update_airline(airline, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_airline(%Airline{} = airline, attrs) do
    airline
    |> Airline.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Airline.

  ## Examples

      iex> delete_airline(airline)
      {:ok, %Airline{}}

      iex> delete_airline(airline)
      {:error, %Ecto.Changeset{}}

  """
  def delete_airline(%Airline{} = airline) do
    Repo.delete(airline)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking airline changes.

  ## Examples

      iex> change_airline(airline)
      %Ecto.Changeset{source: %Airline{}}

  """
  def change_airline(%Airline{} = airline) do
    Airline.changeset(airline, %{})
  end

  alias Myflightmap.Transport.Airport

  @doc """
  Returns the list of airports.

  ## Examples

      iex> list_airports()
      [%Airport{}, ...]

  """
  def list_airports do
    Airport
    |> order_by(:iata_code)
    |> Repo.all
  end

  @doc """
  Gets a single airport.

  Raises `Ecto.NoResultsError` if the Airport does not exist.

  ## Examples

      iex> get_airport!(123)
      %Airport{}

      iex> get_airport!(456)
      ** (Ecto.NoResultsError)

  """
  def get_airport!(id), do: Repo.get!(Airport, id)

  @doc """
  Creates a airport.

  ## Examples

      iex> create_airport(%{field: value})
      {:ok, %Airport{}}

      iex> create_airport(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_airport(attrs \\ %{}) do
    %Airport{}
    |> Airport.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a airport.

  ## Examples

      iex> update_airport(airport, %{field: new_value})
      {:ok, %Airport{}}

      iex> update_airport(airport, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_airport(%Airport{} = airport, attrs) do
    airport
    |> Airport.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Airport.

  ## Examples

      iex> delete_airport(airport)
      {:ok, %Airport{}}

      iex> delete_airport(airport)
      {:error, %Ecto.Changeset{}}

  """
  def delete_airport(%Airport{} = airport) do
    Repo.delete(airport)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking airport changes.

  ## Examples

      iex> change_airport(airport)
      %Ecto.Changeset{source: %Airport{}}

  """
  def change_airport(%Airport{} = airport) do
    Airport.changeset(airport, %{})
  end
end
