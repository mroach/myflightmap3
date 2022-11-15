defmodule Myflightmap.Transport.Airline do
  @moduledoc """
  Schema for airlines
  """

  use Myflightmap.Schema
  import Ecto.Changeset
  alias Myflightmap.Values

  schema "airlines" do
    field :name, :string
    field :iata_code, :string
    field :icao_code, :string
    field :country, :string
    field :commenced_on, :date
    field :ceased_on, :date
    field :alliance, :string
    field :flight_count, :integer

    timestamps()
  end

  @doc false
  # We don't validate uniqueness of IATA code since they get reused.
  # For example, CX was Crossair, then got assigned to the new Swiss International
  def changeset(airline, attrs) do
    airline
    |> cast(attrs, [:iata_code, :icao_code, :name, :country, :commenced_on, :ceased_on, :alliance])
    |> validate_required([:name, :icao_code])
    |> validate_format(:iata_code, ~r/\A[A-Z0-9]{2}\z/)
    |> validate_format(:icao_code, ~r/\A[A-Z]{3}\z/)
    |> validate_inclusion(:country, Values.country_codes())
  end
end
