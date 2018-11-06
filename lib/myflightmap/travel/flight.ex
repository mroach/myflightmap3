defmodule Myflightmap.Travel.Flight do
  @moduledoc """
  A flight owned by a user.
  """

  use Ecto.Schema
  import Ecto.Changeset
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
    :trip_id, :airline_id, :depart_airport_id, :arrive_airport_id, :aircraft_type_id,
    :flight_code, :depart_date, :depart_time, :arrive_date, :arrive_time,
    :seat_class, :seat, :aircraft_registration, :confirmation_number
  ]

  @doc false
  def changeset(flight, attrs) do
    flight
    |> cast(attrs, @writable_attributes)
    |> validate_required([:depart_date])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:trip_id)
    |> foreign_key_constraint(:depart_airport_id)
    |> foreign_key_constraint(:arrive_airport_id)
    |> foreign_key_constraint(:aircraft_type_id)
    |> foreign_key_constraint(:airline_id)
    |> validate_number(:distance, greater_than_or_equal_to: 0)
    |> validate_number(:duration, greater_than_or_equal_to: 0)
  end

  def change_duration(flight) do
    change(flight, duration: calculated_duration(flight))
  end

  def change_distance(flight) do
    change(flight, distance: calculated_distance(flight))
  end

  def calculated_duration(%__MODULE__{} = flight) do
    with %DateTime{} = depart_at <- depart_at(flight),
         %DateTime{} = arrive_at <- arrive_at(flight)
      do
        Timex.diff(arrive_at, depart_at, :minutes)
      else
        _ -> nil
      end
  end

  def calculated_distance(%__MODULE__{} = flight) do
    with %Airport{} = depart_airport <- flight.depart_airport,
         %Airport{} = arrive_airport <- flight.arrive_airport
    do
      Transport.distance_between_airports(depart_airport, arrive_airport)
    else
      _ -> nil
    end
  end

  @doc """
  Full `DateTime` of the departure. Only available when the date, time, and
  departure airport are set on the flight. Otherwise, `nil`.
  """
  def depart_at(%__MODULE__{} = flight), do: movement_date_time(flight, :depart)

  @doc """
  Full `DateTime` of the arrival. Only available when the date, time, and
  arrival airport are set on the flight. Otherwise, `nil`.
  """
  def arrive_at(%__MODULE__{} = flight), do: movement_date_time(flight, :arrive)

  defp movement_date_time(%__MODULE__{} = flight, movement)
    when movement in [:depart, :arrive] do

    with %Date{} = date <- Map.get(flight, :"#{movement}_date"),
         %Time{} = time <- Map.get(flight, :"#{movement}_time"),
         %Airport{} = airport <- Map.get(flight, :"#{movement}_airport"),
         {:ok, datetime} = _ <- NaiveDateTime.new(date, time)
    do
      Timex.to_datetime(datetime, airport.timezone)
    else
      _ -> nil
    end
  end
end
