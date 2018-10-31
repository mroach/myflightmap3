defmodule MyflightmapWeb.AirlineView do
  use MyflightmapWeb, :view

  import MyflightmapWeb.Helpers.FormattingHelpers

  def country_options do
    Countries.all |> Enum.map(fn c -> {c.name, c.alpha2} end)
  end
end
