defmodule MyflightmapWeb.FlightView do
  use MyflightmapWeb, :view
  import MyflightmapWeb.Helpers.DateTimeHelpers
  alias Myflightmap.Transport
  alias Myflightmap.Transport.Airport
  alias Myflightmap.Travel.Flight
  alias Timex.Duration

  def airport_options, do: Transport.list_airport_options
  def airline_options, do: Transport.list_airline_options
  def aircraft_type_options, do: Transport.list_aircraft_type_options
  def seat_class_options do
    [
      {"Economy", "economy"},
      {"Premium Economy", "premium_economy"},
      {"Business", "business"},
      {"First", "first"},
      {"Suites", "suites"}
    ]
  end

  def seat_class_label(nil), do: nil
  def seat_class_label(seat_class) do
    seat_class_options()
    |> Enum.find(fn {_, value} -> value == seat_class end)
    |> case do
      {label, _value} -> label
      _ -> nil
    end
  end

  @doc """
  Provide an unambiguous name for the airport. If a `metro_code` is present
  that means the airport is one of many in a city and we need to use a longer-form
  name of the airport. When no `metro_code` is present we can be reasonably sure
  there's only one airport in the city so using the city name is enough
  """
  def airport_name(%Airport{metro_code: nil, city: city}), do: city
  def airport_name(%Airport{common_name: name}), do: name

  def date_offset(%Flight{arrive_date: nil}), do: nil
  def date_offset(%Flight{depart_date: dd, arrive_date: ad}) when dd == ad, do: nil
  def date_offset(%Flight{depart_date: dd, arrive_date: ad}) do
    format_offset(Date.diff(ad, dd))
  end

  def format_offset(0), do: nil
  def format_offset(num) when num < 0, do: "-#{num}"
  def format_offset(num) when num > 0, do: "+#{num}"

  def format_distance(radians, units \\ :km)
  def format_distance(radians, units) when is_number(radians) do
    whole_units =
      radians
      |> Geo.radians_to(units)
      |> trunc
    "#{whole_units} #{units}"
  end
  def format_distance(_, _), do: nil

  def format_duration(nil), do: nil
  def format_duration(0), do: nil
  def format_duration(minutes) when is_number(minutes) do
    minutes
    |> Duration.from_minutes
    |> Duration.to_clock
    |> format_duration
  end
  def format_duration({0, min, _, _}) do
    "#{min} min"
  end
  def format_duration({hours, minutes, _, _}) do
    "#{hours} hr #{minutes} min"
  end

  def airline(nil), do: nil
  def airline(%{name: name}), do: name
end
