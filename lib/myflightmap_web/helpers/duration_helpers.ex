defmodule MyflightmapWeb.Helpers.DurationHelpers do
  @moduledoc false

  alias Timex.Duration

  @doc """
  Format a time change. Usually the difference between two timezones.
  When giving the input as an integer, it's expected to be in seconds.
  When input is a tuple, it's expected to be `{hours, minutes, seconds, ms}`
  The result will be a string prefixed with a + or - to indicate the change.

  ### Examples:
      iex> MyflightmapWeb.Helpers.DurationHelpers.format_timechange(0)
      nil

      iex> MyflightmapWeb.Helpers.DurationHelpers.format_timechange(3600)
      "+1h"

      iex> MyflightmapWeb.Helpers.DurationHelpers.format_timechange(5400)
      "+1h 30m"
  """
  def format_timechange(0), do: nil
  def format_timechange(nil), do: nil

  def format_timechange(change) when is_integer(change) do
    sign = if change < 0, do: "-", else: "+"

    change
    |> Kernel.abs()
    |> Duration.from_seconds()
    |> Duration.to_clock()
    |> format_clock
    |> (fn s -> sign <> s end).()
  end

  @doc """
  Formats a clock tuple that has `{hours, minutes, seconds, microseconds}`.
  Only hours and minutes are shown

  ### Examples:
      iex> MyflightmapWeb.Helpers.DurationHelpers.format_clock({1, 30, 0, 0})
      "1h 30m"

      iex> MyflightmapWeb.Helpers.DurationHelpers.format_clock({9, 0, 0, 0})
      "9h"

      iex> MyflightmapWeb.Helpers.DurationHelpers.format_clock({0, 45, 0, 0})
      "45m"
  """
  def format_clock({0, 0, _, _}), do: nil
  def format_clock({0, mins, _, _}), do: "#{mins}m"
  def format_clock({hrs, 0, _, _}), do: "#{hrs}h"
  def format_clock({hrs, mins, _, _}), do: "#{hrs}h #{mins}m"

  def format_duration(nil), do: nil
  def format_duration(0), do: nil

  def format_duration(minutes) when is_number(minutes) do
    minutes
    |> Duration.from_minutes()
    |> Duration.to_clock()
    |> format_clock()
  end

  def hours(nil), do: nil
  def hours(0), do: 0

  def hours(minutes) when is_number(minutes) do
    {hrs, _, _, _} =
      minutes
      |> Duration.from_minutes()
      |> Duration.to_clock()

    hrs
  end
end
