defmodule Myflightmap.Repo.Migrations.CreateAirlines do
  use Ecto.Migration

  def change do
    create table(:airlines) do
      add :iata_code,    :string, size: 2
      add :icao_code,    :string, size: 3
      add :name,         :string, null: false
      add :country,      :string, size: 2
      add :commenced_on, :date
      add :ceased_on,    :date
      add :alliance,     :string

      timestamps()
    end

    create index(:airlines, [:iata_code, :commenced_on])
    create index(:airlines, [:icao_code, :commenced_on])
    create index(:airlines, :alliance)
    create index(:airlines, :country)
  end
end
