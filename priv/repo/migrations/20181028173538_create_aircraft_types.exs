defmodule Myflightmap.Repo.Migrations.CreateAircraftTypes do
  use Ecto.Migration

  def change do
    create table(:aircraft_types) do
      add :iata_code, :string, size: 3, null: false
      add :icao_code, :string, size: 4
      add :manufacturer_code, :string
      add :description, :string, null: false
      add :engine_type, :string
      add :engine_count, :integer

      timestamps()
    end

    create index(:aircraft_types, :iata_code, unique: true)
    create index(:aircraft_types, :icao_code)
    create index(:aircraft_types, :manufacturer_code)
    create index(:aircraft_types, :description)
  end
end
