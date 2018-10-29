defmodule Myflightmap.Transport.Aircraft do
  use Ecto.Schema
  import Ecto.Changeset


  schema "aircraft" do
    field :iata_code, :string
    field :icao_code, :string
    field :manufacturer_code, :string
    field :description, :string
    field :engine_type, :string
    field :engine_count, :integer

    timestamps()
  end

  @doc false
  def changeset(aircraft, attrs) do
    aircraft
    |> cast(attrs, [:iata_code, :icao_code, :manufacturer_code, :description, :engine_type, :engine_count])
    |> validate_required([:iata_code, :description])
    |> unique_constraint(:iata_code)
  end
end
