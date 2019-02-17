defmodule MyflightmapWeb.Helpers.DistanceHelpers do
  @moduledoc false

  @doc """
  Take a distance in radians and convert it to the given units and format it.

  Example:
      iex> MyflightmapWeb.Helpers.DistanceHelpers.format_distance(0.88232, :km)
      "5621 km"
  """
  def format_distance(input, units \\ :km)
  def format_distance(radians, units) when is_number(radians) do
    whole_units =
      radians
      |> Geo.radians_to(units)
      |> trunc
    "#{whole_units} #{units}"
  end
  def format_distance(_, _), do: nil
end
