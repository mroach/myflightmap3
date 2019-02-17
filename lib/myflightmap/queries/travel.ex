defmodule Myflightmap.Queries.Travel do
  import Ecto.Query, warn: false
  alias Myflightmap.Transport.{Airline, Airport}
  alias Myflightmap.Travel.Flight

  def top_airports(query \\ Flight) do
    from a in Airport,
    join: m in subquery(airport_movement_counts(query)),
      on: m.airport_id == a.id,
    order_by: [desc: m.movements],
    select: %{airport: a, movements: m.movements}
  end

  @doc """
  Top airlines seen in the given `Flight`-based query.
  """
  def top_airlines(query \\ Flight) do
    from a in Airline,
    join: m in subquery(airline_movement_counts(query)),
      on: m.airline_id == a.id,
    order_by: [desc: m.movements],
    select: %{airline: a, movements: m.movements}
  end

  @doc """
  Uses the total movements per airport to calculate the number of movements
  seen in countries.
  For example if you have two flights: Munich -> Berlin, Berlin -> Paris
  Your movement counts are 3 for Germany, 1 for France.
  """
  def top_countries(query \\ Flight) do
    from a in Airport,
    join: m in subquery(airport_movements(query)),
      on: m.airport_id == a.id,
    group_by: a.country,
    order_by: [desc: count(a.country)],
    select: %{country: a.country, movements: count(a.country)}
  end

  def distinct_country_count(query \\ Flight) do
    from a in Airport,
    join: m in subquery(airport_movements(query)),
      on: m.airport_id == a.id,
    select: count(a.country, :distinct)
  end

  @doc """
  Unifies the departure and arrival airports into a single column of `airport_id`
  """
  def airport_movements(query \\ Flight) do
    departures = movements(query, :depart_airport_id)
    arrivals = movements(query, :arrive_airport_id)

    union_all(departures, ^arrivals)
  end

  def distinct_airline_count(query \\ Flight) do
    from f in query,
    select: count(f.airline_id, :distinct)
  end

  def duration_summary(query \\ Flight) do
    from f in query,
    select: %{
      avg: avg(f.duration),
      sum: sum(f.duration),
      min: min(f.duration),
      max: max(f.duration)
    }
  end

  def distance_summary(query \\ Flight) do
    from f in query,
    select: %{
      avg: avg(f.distance),
      sum: sum(f.distance),
      min: min(f.distance),
      max: max(f.distance)
    }
  end

  defp airline_movement_counts(query \\ Flight) do
    from f in query,
    group_by: f.airline_id,
    select: %{
      airline_id: f.airline_id,
      movements: count(f.airline_id)
    }
  end

  @doc """
  Union of departure and arrival airports as a single list of airport IDs
  and the number of movements seen at each.
  """
  defp airport_movement_counts(query \\ Flight) do
    from m in subquery(airport_movements(query)),
    group_by: m.airport_id,
    select: %{
      airport_id: m.airport_id,
      movements: count(m.airport_id)
    }
  end

  # Extracts the departure or arrival airport ID as a single field
  defp movements(query, field)
    when field in [:depart_airport_id, :arrive_airport_id] do

    from f in query, select: %{airport_id: field(f, ^field)}
  end
end
