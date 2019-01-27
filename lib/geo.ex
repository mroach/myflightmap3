defmodule Geo do
  @moduledoc """
  Helper for calculating geographic distances, such as between airports.
  The Earth isn't a perfect sphere, so the radius values used are averages
  generally accepted for non-pinpoint accurate distance calculation.
  """

  @earth_radius_km 6371
  @earth_radius_sm 3958.748
  @earth_radius_nm 3440.065
  @feet_per_sm 5280

  @d2r :math.pi / 180

  @units [:km, :sm, :nm, :m, :ft]

  @doc """
  Convert degrees to radians
  """
  def deg_to_rad(deg), do: deg * @d2r

  def radians_to(radians, :km), do: radians * @earth_radius_km
  def radians_to(radians, :sm), do: radians * @earth_radius_sm
  def radians_to(radians, :nm), do: radians * @earth_radius_nm
  def radians_to(radians, :m), do: radians * @earth_radius_km * 1000
  def radians_to(radians, :ft), do: radians * @earth_radius_sm * @feet_per_sm

  @doc """
  ## Examples:
    iex> Geo.great_circle_distance({53.630389, 9.988228}, {48.353783, 11.786086}, :km) |> Float.floor
    600.0

    iex> Geo.great_circle_distance({-31.940277, 115.966944}, {49.194722, -123.183888}, :nm) |> Float.floor
    7998.0

    iex> Geo.great_circle_distance({-23.435555, -46.473055}, {-26.133693, 28.242317}, :sm) |> Float.floor
    4622.0
  """
  def great_circle_distance(p1, p2, unit) when unit in(@units) do
    radians_to(haversine(p1, p2), unit)
  end

  @doc """
  Calculate the [Haversine](https://en.wikipedia.org/wiki/Haversine_formula)
  distance between two coordinates. Result is in radians. This result can be
  multiplied by the sphere's radius in any unit to get the distance in that unit.

  For example, multiple the result of this function by the Earth's radius in
  kilometres and you get the distance between the two given points in kilometres.
  """
  def haversine(%{x: lat1, y: lon1}, %{x: lat2, y: lon2}), do: haversine({lat1, lon1}, {lat2, lon2})
  def haversine({lat1, lon1}, {lat2, lon2}) do
    dlat = deg_to_rad(lat2 - lat1)
    dlon = deg_to_rad(lon2 - lon1)

    radlat1 = deg_to_rad(lat1)
    radlat2 = deg_to_rad(lat2)

    a = :math.pow(:math.sin(dlat / 2), 2) +
        :math.pow(:math.sin(dlon / 2), 2) *
        :math.cos(radlat1) * :math.cos(radlat2)

    2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
  end
end
