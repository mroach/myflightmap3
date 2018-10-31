defmodule MyflightmapWeb.AirportView do
  use MyflightmapWeb, :view
  alias Myflightmap.Transport.Airport

  import MyflightmapWeb.Helpers.FormattingHelpers

  def timezone_options do
    Tzdata.canonical_zone_list
    |> Enum.map(fn z -> {z, z} end)
  end

  def country_options do
    Countries.all |> Enum.map(fn c -> {c.name, c.alpha2} end)
  end

  def status(%Airport{closed_on: nil}), do: gettext("Active")
  def status(%Airport{closed_on: closed_on}) do
    case Date.compare(closed_on, Date.utc_today()) do
      :lt -> gettext("Closed")
      _ -> gettext("Active")
    end
  end
end
