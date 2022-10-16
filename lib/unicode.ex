defmodule Unicode do
  @moduledoc """
  Helpers for working with emoji
  """

  @regional_indicator_start 0x1F1E6

  @doc """
  Take a two-character country code and convert it to an emoji flag

  Example:
      iex> Unicode.emoji_flag("au")
      "🇦🇺"
  """
  def emoji_flag(str) when is_binary(str), do: str |> String.upcase() |> regional_indicator

  @doc """
  Take two ASCII characters and convert them to their Unicode
  "Regional Indicator Symbol" equivalents.
  Two adjacent RIS's get displayed as a flag on most platforms.
  """
  def regional_indicator(<<a, b>>) do
    [a, b]
    |> Enum.map(&regional_indicator/1)
    |> List.to_string()
  end

  def regional_indicator(char) when is_number(char) and char >= ?A and char <= ?Z do
    char + @regional_indicator_start - ?A
  end

  def regional_indicator(_), do: nil
end
