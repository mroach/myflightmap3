defmodule Myflightmap.Repo.Migrations.AddTripEmailIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :trip_email_id, :string
    end

    create index(:users, :trip_email_id, unique: true)
  end
end
