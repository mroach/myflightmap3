defmodule Myflightmap.Transport do
  @moduledoc """
  The Transport context.
  """

  import Ecto.Query, warn: false
  alias Myflightmap.Repo
  alias Myflightmap.Transport.Airline

  def list_seat_classes do
    [
      %{value: "economy", name: "Economy"},
      %{value: "premium_economy", name: "Premium Economy"},
      %{value: "business", name: "Business"},
      %{value: "first", name: "First"},
      %{value: "suites", name: "Suites"}
    ]
  end

  def list_seat_class_options do
    list_seat_classes()
    |> Enum.map(fn %{value: value, name: name} -> {value, name} end )
  end

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

  def list_airline_options do
    query = from a in Airline,
            order_by: a.iata_code,
            select: {a.id, a.iata_code, a.name}

    query
    |> Repo.all
    |> Enum.map(fn {id, iata, name} -> {"#{iata} #{name}", id} end)
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

  def list_airport_options do
    query = from a in Airport, select: {a.id, a.common_name, a.iata_code}

    query
    |> Repo.all
    |> Enum.map(fn {id, name, iata} -> {"#{name} (#{iata})", id} end)
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

  def get_airport_by_iata!(code), do: Repo.get_by!(Airport, iata_code: code)

  def get_airport_by_icao!(code), do: Repo.get_by!(Airport, icao_code: code)

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

  def distance_between_airports(airport_1_id, airport_2_id)
    when is_integer(airport_1_id) and is_integer(airport_2_id) do

    airport_1 = get_airport!(airport_1_id)
    airport_2 = get_airport!(airport_2_id)

    distance_between_airports(airport_1, airport_2)
  end
  def distance_between_airports(%Airport{coordinates: c1}, %Airport{coordinates: c2}) do
    Geo.haversine(c1, c2)
  end

  alias Myflightmap.Transport.AircraftType

  @doc """
  Returns the list of aircraft types.

  ## Examples

      iex> list_aircraft_types()
      [%AircraftType{}, ...]

  """
  def list_aircraft_types do
    AircraftType
    |> order_by(:icao_code)
    |> Repo.all
  end

  def list_aircraft_type_options do
    query = from a in AircraftType, order_by: a.description, select: {a.description, a.id}
    Repo.all(query)
  end

  @doc """
  Gets a single aircraft type.

  Raises `Ecto.NoResultsError` if the aircraft type does not exist.

  ## Examples

      iex> get_aircraft_type!(123)
      %AircraftType}

      iex> get_aircraft_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_aircraft_type!(id), do: Repo.get!(AircraftType, id)

  @doc """
  Creates an aircraft type.

  ## Examples

      iex> create_aircraft_type(%{field: value})
      {:ok, %AircraftType{}}

      iex> create_aircraft_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_aircraft_type(attrs \\ %{}) do
    %AircraftType{}
    |> AircraftType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an aircraft type.

  ## Examples

      iex> update_aircraft_type(aircraft_type, %{field: new_value})
      {:ok, %AircraftType{}}

      iex> update_aircraft_type(aircraft_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_aircraft_type(%AircraftType{} = aircraft_type, attrs) do
    aircraft_type
    |> AircraftType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an aircraft type.

  ## Examples

      iex> delete_aircraft_type(aircraft_type)
      {:ok, %AircrafType{}}

      iex> delete_aircraft_type(aircraft_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_aircraft_type(%AircraftType{} = aircraft_type) do
    Repo.delete(aircraft_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking aircraft type changes.

  ## Examples

      iex> change_aircraft_type(aircraft_type)
      %Ecto.Changeset{source: %AircraftType{}}

  """
  def change_aircraft_type(%AircraftType{} = aircraft_type) do
    AircraftType.changeset(aircraft_type, %{})
  end
end
