defmodule MyflightmapWeb.AirportView do
  use MyflightmapWeb, :view

  import MyflightmapWeb.FormattingHelpers

  def timezone_options do
    Tzdata.canonical_zone_list
    |> Enum.map(fn z -> {z, z} end)
  end

  def country_options do
    Countries.all |> Enum.map(fn c -> {c.name, c.alpha2} end)
  end
end
