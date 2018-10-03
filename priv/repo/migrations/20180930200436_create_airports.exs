defmodule Myflightmap.Repo.Migrations.CreateAirports do
  use Ecto.Migration

  def change do
    create table(:airports) do
      add :iata_code, :string, size: 3
      add :icao_code, :string, size: 4
      add :country, :string, size: 2
      add :city, :string
      add :full_name, :string
      add :common_name, :string
      add :metro_code, :string, size: 3
      add :timezone, :string, size: 100
      add :coordinates, :point
      add :opened_on, :date
      add :closed_on, :date

      timestamps()
    end

    create unique_index(:airports, [:iata_code, :opened_on])
    create unique_index(:airports, [:icao_code, :opened_on])
    create index(:airports, :country)
    create index(:airports, :metro_code)
  end
end
