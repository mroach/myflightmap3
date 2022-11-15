defmodule MyflightmapWeb.Helpers.AirlineHelpers do
  @logo_path "priv/static/images/airlines/logos"
  @available_logos @logo_path
    |> Path.join("*.png")
    |> Path.wildcard()
    |> Enum.map(fn p -> Path.basename(p, ".png") end)
    |> Enum.sort()

  alias Myflightmap.Transport.Airline

  def available_logos, do: @available_logos

  def airline_logo(source, size \\ 5)

  def airline_logo(%Airline{iata_code: code}, size) when is_binary(code) do
    airline_logo(code, size)
  end

  def airline_logo(code, size) when code in @available_logos do
    Phoenix.HTML.Tag.img_tag(
      "/images/airlines/logos/#{code}.png",
      class: "object-contain w-#{size} h-#{size}"
    )
  end

  def airline_logo(val, _), do: nil

  def airline_logo_available?(%Airline{iata_code: code}), do: airline_logo_available?(code)
  def airline_logo_available?(code) when code in @available_logos, do: true
  def airline_logo_available?(_), do: false
end
