defmodule Myflightmap.Transport.AircraftType do
  @moduledoc """
  An aircraft type is a model of aircraft made by a manufacturer.
  For example a Boeing 777-300ER, or a Canadair RJ 900
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "aircraft_types" do
    field :iata_code, :string
    field :icao_code, :string
    field :manufacturer_code, :string
    field :description, :string
    field :engine_type, :string
    field :engine_count, :integer

    timestamps()
  end

  @doc false
  def changeset(aircraft_type, attrs) do
    aircraft_type
    |> cast(attrs, [:iata_code, :icao_code, :manufacturer_code, :description, :engine_type, :engine_count])
    |> validate_required([:iata_code, :description])
    |> unique_constraint(:iata_code)
    |> validate_number(:engine_count, greater_than: 0, less_than: 10)
  end
end
