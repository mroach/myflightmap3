defmodule Myflightmap.Repo.Migrations.AddCounterCaches do
  use Ecto.Migration

  @tables [:airlines, :airports]

  def up do
    for table <- @tables do
      alter table(table), do: add :flight_count, :integer, default: 0
    end

    flush()

    repo().query!(~s"""
      UPDATE airports SET flight_count = (
        SELECT COUNT (*)
        FROM flights
        WHERE depart_airport_id = airports.id
          OR arrive_airport_id = airports.id
      )
    """)

    repo().query!(~s"""
      UPDATE airlines SET flight_count = (
        SELECT COUNT (*)
        FROM flights
        WHERE airline_id = airlines.id
      )
    """)

    flush()

    for table <- @tables do
      alter table(table), do: modify :flight_count, :integer, null: false

      create index(table, :flight_count)
      create constraint(table, "flight_count_must_be_positive", check: "flight_count >= 0")
    end
  end

  def down do
    for table <- @tables do
      alter table(table), do: remove :flight_count
    end
  end
end
