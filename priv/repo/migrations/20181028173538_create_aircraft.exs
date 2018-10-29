defmodule Myflightmap.Repo.Migrations.CreateAircraft do
  use Ecto.Migration

  def change do
    create table(:aircraft) do
      add :iata_code, :string
      add :icao_code, :string
      add :manufacturer_code, :string
      add :description, :string
      add :engine_type, :string
      add :engine_count, :integer

      timestamps()
    end

    create index(:aircraft, :iata_code, unique: true)
    create index(:aircraft, :icao_code)
    create index(:aircraft, :manufacturer_code)
    create index(:aircraft, :description)
  end
end
