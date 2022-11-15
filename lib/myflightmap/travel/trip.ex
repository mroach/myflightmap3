defmodule Myflightmap.Travel.Trip do
  @moduledoc """
  Schema for a trip. A trip belongs to a user and groups flights together.
  These are optional in the trip logging realms
  """

  use Myflightmap.Schema
  import Ecto.Changeset
  alias Myflightmap.Accounts.User
  alias Myflightmap.Travel.Flight

  schema "trips" do
    field :name, :string
    field :privacy, :string, default: "public"
    field :purpose, :string
    field :start_date, :date
    field :end_date, :date
    belongs_to :user, User
    has_many :flights, Flight

    timestamps()
  end

  @doc false
  def changeset(trip, attrs) do
    trip
    |> cast(attrs, [:name, :purpose, :start_date, :end_date, :privacy])
    |> validate_required([:name, :privacy])
    |> foreign_key_constraint(:user_id)
  end
end
