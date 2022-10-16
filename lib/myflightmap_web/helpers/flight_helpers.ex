defmodule MyflightmapWeb.Helpers.FlightHelpers do
  @moduledoc false

  alias Myflightmap.Transport
  alias Myflightmap.Travel.Flight
  alias MyflightmapWeb.Helpers.{DistanceHelpers, DurationHelpers}

  import MyflightmapWeb.Helpers.AirportHelpers, only: [airport_name: 1]

  def seat_class_name(%Flight{seat_class: seat_class}), do: seat_class_name(seat_class)
  def seat_class_name(nil), do: nil

  def seat_class_name(seat_class) do
    Transport.list_seat_classes()
    |> Enum.find(fn %{value: value} -> value == seat_class end)
    |> case do
      %{name: name} -> name
      _ -> seat_class
    end
  end

  @doc """
  Determine the day offset of the arrival. For example flying from the US to
  Europe overnight, the offset is +1. A short flight is usually 0.
  Negative numbers are exceptionally rare but can happen.
  """
  def arrival_day_offset(%Flight{arrive_date: nil}), do: nil
  def arrival_day_offset(%Flight{depart_date: dd, arrive_date: ad}) when dd == ad, do: 0
  def arrival_day_offset(%Flight{depart_date: dd, arrive_date: ad}), do: Date.diff(ad, dd)

  def formatted_arrival_day_offset(%Flight{} = flight) do
    flight
    |> arrival_day_offset
    |> format_arrival_day_offset
  end

  defp format_arrival_day_offset(0), do: nil
  defp format_arrival_day_offset(nil), do: nil
  defp format_arrival_day_offset(offset) when offset > 0, do: "+#{offset}"
  defp format_arrival_day_offset(offset) when offset < 0, do: "+#{offset}"

  def formatted_distance(flight, units \\ :km)

  def formatted_distance(%Flight{distance: distance}, units) when is_number(distance) do
    DistanceHelpers.format_distance(distance, units)
  end

  def formatted_distance(_, _), do: nil

  def formatted_duration(%Flight{duration: duration}) when is_number(duration) do
    DurationHelpers.format_duration(duration)
  end

  def formatted_duration(_), do: nil

  def airline_name(%Flight{airline: %{name: name}}), do: name
  def airline_name(_), do: nil

  def aircraft_type_name(%Flight{aircraft_type: %{description: desc}}), do: desc
  def aircraft_type_name(_), do: nil

  def depart_airport_name(%Flight{depart_airport: ap}), do: airport_name(ap)
  def arrive_airport_name(%Flight{arrive_airport: ap}), do: airport_name(ap)

  @doc """
  The time difference between the departure and arrival airports of the flight.
  The return value is the difference in seconds. For example flying from
  London to Berlin, the difference is 3600. Then flying Berlin to London is -3600.
  """
  def timezone_change(%Flight{} = flight) do
    with %DateTime{} = depart_at <- Flight.depart_at(flight),
         %DateTime{} = arrive_at <- Flight.arrive_at(flight) do
      timezone_difference(arrive_at, depart_at)
    else
      _ -> nil
    end
  end

  def formatted_timechange(%Flight{} = flight) do
    flight |> timezone_change() |> DurationHelpers.format_timechange()
  end

  # Timezone difference in seconds between the two datetimes
  defp timezone_difference(%DateTime{} = t1, %DateTime{} = t2) do
    t1.utc_offset + t1.std_offset - (t2.utc_offset + t2.std_offset)
  end
end
