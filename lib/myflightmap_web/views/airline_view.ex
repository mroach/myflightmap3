defmodule MyflightmapWeb.AirlineView do
  use MyflightmapWeb, :view
  alias Myflightmap.Transport.Airline

  def emoji_flag(%Airline{country: code}), do: code |> emoji_flag
  def emoji_flag(code) when is_binary(code) do
    code |> Unicode.emoji_flag
  end
  def emoji_flag(_), do: nil
end
