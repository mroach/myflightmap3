defmodule Myflightmap.Repo.Migrations.CreateFlights do
  use Ecto.Migration

  def change do
    create table(:flights) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :trip_id, references(:trips, on_delete: :nilify_all)
      add :flight_code, :string
      add :airline_id, references(:airlines, on_delete: :restrict)
      add :depart_airport_id, references(:airports, on_delete: :restrict), null: false
      add :arrive_airport_id, references(:airports, on_delete: :restrict), null: false
      add :depart_date, :date, null: false
      add :depart_time, :time
      add :arrive_date, :date
      add :arrive_time, :time
      add :seat_class, :string
      add :seat, :string
      add :aircraft_registration, :string
      add :duration, :integer
      add :distance, :integer
      add :confirmation_number, :string
      add :aircraft_type_id, references(:aircraft_types, on_delete: :restrict)

      timestamps()
    end

    create index(:flights, [:user_id, :depart_date, :depart_time])
    create index(:flights, [:trip_id, :depart_date, :depart_time])
    create index(:flights, [:airline_id])
    create index(:flights, [:depart_airport_id])
    create index(:flights, [:arrive_airport_id])
    create index(:flights, [:aircraft_type_id])
  end
end
