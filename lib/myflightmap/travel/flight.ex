defmodule Myflightmap.Travel.Flight do
  use Ecto.Schema
  import Ecto.Changeset
  alias Myflightmap.Accounts.User
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
    field :distance, :integer
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
    :seat_class, :seat, :aircraft_registration, :duration, :distance, :confirmation_number
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
end
