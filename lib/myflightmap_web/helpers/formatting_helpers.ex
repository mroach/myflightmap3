defmodule MyflightmapWeb.Helpers.FormattingHelpers do
  @moduledoc """
  Common formatting helpers that could be included in
  """
  def emoji_flag(%{country: code}), do: code |> emoji_flag
  def emoji_flag(%{country_code: code}), do: code |> emoji_flag
  def emoji_flag(code) when is_binary(code) do
    code |> Unicode.emoji_flag
  end
  def emoji_flag(_), do: nil

  @doc """
  Get a country's name by ISO code

  Examples:
      iex> MyflightmapWeb.FormattingHelpers.country_name("SG")
      "Singapore"
  """
  def country_name(code) when is_binary(code) do
    case Countries.filter_by(:alpha2, code) do
      [%Countries.Country{} = c] -> c.name
      _ -> code
    end
  end
  def country_name(_), do: nil
end
