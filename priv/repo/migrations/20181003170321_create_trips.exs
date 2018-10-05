defmodule Myflightmap.Repo.Migrations.CreateTrips do
  use Ecto.Migration

  def change do
    create table(:trips) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :name, :string
      add :purpose, :string
      add :start_date, :date
      add :end_date, :date
      add :privacy, :string

      timestamps()
    end

    create index(:trips, [:user_id])
    create index(:trips, [:privacy])
  end
end
