defmodule Myflightmap.Transport.Airport do
  @moduledoc """
  Schema for airports
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Myflightmap.Values

  schema "airports" do
    field :city, :string
    field :common_name, :string
    field :coordinates, Point
    field :country, :string
    field :full_name, :string
    field :iata_code, :string
    field :icao_code, :string
    field :metro_code, :string
    field :opened_on, :date
    field :closed_on, :date
    field :timezone, :string

    timestamps()
  end

  @writable_attributes [
    :iata_code, :icao_code, :metro_code, :country, :city, :timezone,
    :full_name, :common_name, :coordinates, :opened_on, :closed_on]

  @doc false
  def changeset(airport, attrs) do
    airport
    |> cast(attrs, @writable_attributes)
    |> validate_required([:country, :common_name, :timezone, :coordinates])
    |> validate_inclusion(:timezone, Values.timezones())
    |> validate_inclusion(:country, Values.country_codes())
  end
end
