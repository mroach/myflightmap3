defmodule Myflightmap.Travel.Flight do
  @moduledoc """
  A flight owned by a user.
  """

  use Myflightmap.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias Myflightmap.Accounts.User
  alias Myflightmap.Transport
  alias Myflightmap.Transport.{AircraftType, Airline, Airport}
  alias Myflightmap.Travel.Trip

  schema "flights" do
    belongs_to :user, User
    belongs_to :trip, Trip
    belongs_to :airline, Airline
    belongs_to :depart_airport, Airport
    belongs_to :arrive_airport, Airport
    field :flight_code, :string
    field :depart_date, :date
    field :depart_time, :time
    field :arrive_date, :date
    field :arrive_time, :time
    field :distance, :float
    field :duration, :integer
    field :aircraft_registration, :string
    field :confirmation_number, :string
    field :seat, :string
    field :seat_class, :string
    belongs_to :aircraft_type, AircraftType

    timestamps()
  end

  @writable_attributes [
    :user_id,
    :trip_id,
    :airline_id,
    :depart_airport_id,
    :arrive_airport_id,
    :aircraft_type_id,
    :flight_code,
    :depart_date,
    :depart_time,
    :arrive_date,
    :arrive_time,
    :seat_class,
    :seat,
    :aircraft_registration,
    :confirmation_number
  ]

  @required_attributes [
    :depart_date,
    :user_id,
    :depart_airport_id,
    :arrive_airport_id
  ]

  @doc false
  def changeset(flight, attrs) do
    flight
    |> prepare_change(attrs)
    |> validate_required(@required_attributes)
    |> maybe_update_distance()
    |> maybe_update_duration()
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:trip_id)
    |> foreign_key_constraint(:depart_airport_id)
    |> foreign_key_constraint(:arrive_airport_id)
    |> foreign_key_constraint(:aircraft_type_id)
    |> foreign_key_constraint(:airline_id)
    |> prepare_changes(fn changeset ->
      changeset
      |> update_counter_cache(:airline)
      |> update_counter_cache(:depart_airport)
      |> update_counter_cache(:arrive_airport)
    end)
  end

  def prepare_change(flight, attrs) do
    flight
    |> cast(attrs, @writable_attributes)
    |> update_change(:flight_code, &normalize_flight_code/1)
  end

  defp update_counter_cache(c, _), do: c
  # defp update_counter_cache(changeset, assoc_name, counter_field \\ :flight_count) do
  #   %{field: field, related: related, related_key: related_key, owner_key: owner_key} =
  #     __schema__(:association, assoc_name)

  #   old_fk_id = Map.fetch!(changeset.data, field)
  #   new_fk_id = get_change(changeset, field)

  #   if new_fk_id do
  #     if old_fk_id do
  #       query = from related, where: ^[{related_key, old_fk_id}]
  #       changeset.repo.update_all(query, inc: [{counter_field, -1}])
  #     end

  #     query = from related, where: ^[{related_key, new_fk_id}]
  #     changeset.repo.update_all(query, inc: [{counter_field, 1}])
  #   end

  #   changeset
  # end

  def normalize_flight_code(nil), do: nil

  def normalize_flight_code(code) do
    code
    |> String.replace(~r/\s/, "")
    |> String.upcase()
  end

  def change_duration(flight, duration) do
    flight
    |> change(duration: duration)
    |> validate_number(:duration, greater_than_or_equal_to: 0)
  end

  def put_movement_date_time(flight, movement, %DateTime{} = datetime)
      when movement in [:depart, :arrive] do
    flight
    |> Map.put(:"#{movement}_date", datetime |> DateTime.to_date())
    |> Map.put(:"#{movement}_time", datetime |> DateTime.to_time() |> Time.truncate(:second))
  end

  # TODO: Fix all this stuff that relied on associations being loaded.
  def maybe_update_distance(changeset) do
    with true <- Ecto.assoc_loaded?(changeset.data.depart_airport),
         true <- Ecto.assoc_loaded?(changeset.data.arrive_airport) do
      changeset
      |> put_change(:distance, calculated_distance(changeset.data))
      |> validate_number(:distance, greater_than_or_equal_to: 0)
    else
      _ -> changeset
    end
  end

  def maybe_update_duration(changeset) do
    with true <- Ecto.assoc_loaded?(changeset.data.depart_airport),
         true <- Ecto.assoc_loaded?(changeset.data.arrive_airport),
         duration when is_number(duration) <- calculated_duration(changeset) do
      changeset
      |> put_change(:duration, duration)
      |> validate_number(:duration, greater_than_or_equal_to: 0)
    else
      _ -> changeset
    end
  end

  def calculated_duration(flight_or_changeset) do
    with %DateTime{} = depart_at <- depart_at(flight_or_changeset),
         %DateTime{} = arrive_at <- arrive_at(flight_or_changeset) do
      Timex.diff(arrive_at, depart_at, :minutes)
    else
      res -> {:error, res}
    end
  end

  def calculated_distance(flight) do
    with %Airport{} = depart_airport <- flight.depart_airport,
         %Airport{} = arrive_airport <- flight.arrive_airport do
      Transport.distance_between_airports(depart_airport, arrive_airport)
    else
      _ -> nil
    end
  end

  @doc """
  Full `DateTime` of the departure. Only available when the date, time, and
  departure airport are set on the flight. Otherwise, `nil`.
  """
  def depart_at(flight), do: movement_date_time(flight, :depart)

  @doc """
  Full `DateTime` of the arrival. Only available when the date, time, and
  arrival airport are set on the flight. Otherwise, `nil`.
  """
  def arrive_at(flight), do: movement_date_time(flight, :arrive)

  defp movement_date_time(%__MODULE__{} = flight, movement)
       when movement in [:depart, :arrive] do
    with %Date{} = date <- Map.get(flight, :"#{movement}_date"),
         %Time{} = time <- Map.get(flight, :"#{movement}_time"),
         %Airport{} = airport <- Map.get(flight, :"#{movement}_airport"),
         {:ok, datetime} = _ <- NaiveDateTime.new(date, time) do
      Timex.to_datetime(datetime, airport.timezone)
    else
      _ -> nil
    end
  end

  defp movement_date_time(%Ecto.Changeset{} = changeset, movement)
       when movement in [:depart, :arrive] do
    with {_, %Date{} = date} <- fetch_field(changeset, :"#{movement}_date"),
         {_, %Time{} = time} <- fetch_field(changeset, :"#{movement}_time"),
         %Airport{} = airport <- Map.get(changeset.data, :"#{movement}_airport"),
         {:ok, datetime} = _ <- NaiveDateTime.new(date, time) do
      Timex.to_datetime(datetime, airport.timezone)
    else
      _ -> nil
    end
  end
end
