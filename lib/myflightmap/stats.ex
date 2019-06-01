defmodule Myflightmap.Stats do
  alias Myflightmap.Accounts.User
  alias Myflightmap.Queries.Travel, as: TQ
  alias Myflightmap.Repo
  alias Myflightmap.Travel.{Flight, Trip}
  import Ecto.Query

  @default_top_limit 10

  def summary_for(entity) do
    %{
      distance:  distance(entity),
      duration:  duration(entity),
      airlines:  distinct_airlines(entity),
      airports:  distinct_airports(entity),
      countries: distinct_countries(entity),
      flights:   flight_count(entity)
    }
  end

  def top_for(entity, limit \\ @default_top_limit) do
    %{
      airlines:  top_airlines_for(entity, limit),
      airports:  top_airports_for(entity, limit),
      countries: top_countries_for(entity, limit),
    }
  end

  def top_airports_for(entity, result_limit \\ @default_top_limit) do
    entity
    |> query_base()
    |> TQ.top_airports
    |> limit(^result_limit)
    |> Repo.all
  end

  def top_airlines_for(entity, result_limit \\ @default_top_limit) do
    entity
    |> query_base
    |> TQ.top_airlines
    |> limit(^result_limit)
    |> Repo.all
  end

  def top_countries_for(entity, result_limit \\ @default_top_limit) do
    entity
    |> query_base
    |> TQ.top_countries
    |> limit(^result_limit)
    |> Repo.all
    |> Enum.map(fn %{country: code, movements: movements} ->
      %{
        country: load_country(code),
        movements: movements
      }
    end)
  end

  def flight_count(entity) do
    entity
    |> query_base
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Get a count for the number of distinct airlines seen in this query
  """
  def distinct_airlines(entity) do
    entity
    |> query_base
    |> TQ.distinct_airline_count
    |> Repo.one
  end

  @doc """
  Get a count for the number of distinct airports seen in this query
  """
  def distinct_airports(entity) do
    entity
    |> query_base
    |> TQ.airport_movements
    |> subquery
    |> select([f], count(f.airport_id, :distinct))
    |> Repo.one
  end

  def distinct_countries(entity) do
    entity
    |> query_base
    |> TQ.distinct_country_count
    |> Repo.one
  end

  def distance(entity) do
    entity
    |> query_base
    |> TQ.distance_summary
    |> Repo.one
  end

  def duration(entity) do
    entity
    |> query_base
    |> TQ.duration_summary
    |> Repo.one
  end

  defp query_base(%User{id: user_id}) do
    from(f in Flight, where: f.user_id == ^user_id)
  end
  defp query_base(%Trip{id: trip_id}) do
    from(f in Flight, where: f.trip_id == ^trip_id)
  end
  defp query_base(:all), do: from(f in Flight)

  defp load_country(iso_code) do
    case Countries.filter_by(:alpha2, iso_code) do
      [res | _tail] -> res
      _ -> %Countries.Country{alpha2: iso_code}
    end
  end
end
