defmodule MyflightmapWeb.Helpers.DateTimeHelpers do
  @moduledoc """
  Helpers for formatting dates and times. Handles four different kinds of date/time objects:
  * `DateTime`
  * `NaiveDateTime`
  * `Date`
  * `Time`
  """

  @doc """
  Formats a DateTime, Date, or Time object with sensible defaults
  ## Examples
      iex> {:ok, dt, _} = DateTime.from_iso8601("2015-01-23T23:50:07Z")
      ...> IpdustWeb.PageView.date_time_format(dt)
      "23 Jan 2015 23:50 Etc/UTC"
      iex> IpdustWeb.PageView.date_time_format(~T[09:23:19])
      "09:23:19"
      iex> IpdustWeb.PageView.date_time_format(~T[22:01:00])
      "22:01:00"
  """
  def date_time_format(%DateTime{} = date), do: date_time_format(date, "%d %b %Y %H:%M %Z")
  def date_time_format(%NaiveDateTime{} = date), do: date_time_format(date, "%d %b %Y %H:%M %Z")
  def date_time_format(%Date{} = date), do: date_time_format(date, "%d %b %Y")
  def date_time_format(%Time{} = date), do: date_time_format(date, "%H:%M:%S")
  def date_time_format(_), do: nil

  @doc """
  Formats a DateTime, Date, or Time with the given format
  ### Examples
    iex> {:ok, dt, _} = DateTime.from_iso8601("2015-01-23T23:50:07Z")
    ...> IpdustWeb.PageView.date_time_format(dt, "%F")
    "2015-01-23"
    iex> IpdustWeb.PageView.date_time_format(~D[2018-07-23], "%F")
    "2018-07-23"
    iex> IpdustWeb.PageView.date_time_format(~D[2018-07-23], "%d.%m.%Y")
    "23.07.2018"
    iex> IpdustWeb.PageView.date_time_format(~T[22:01:00], "%I:%M %p")
    "10:01 PM"
  """
  def date_time_format(%DateTime{} = date, format), do: strftime(date, format)
  def date_time_format(%NaiveDateTime{} = date, format), do: strftime(date, format)
  def date_time_format(%Date{} = date, format), do: strftime(date, format)
  def date_time_format(%Time{} = date, format), do: strftime(date, format)
  def date_time_format(_, _), do: nil

  defp strftime(date, format) do
    case Timex.format(date, format, :strftime) do
      {:ok, formatted} -> formatted
      _ -> to_string(date)
    end
  end
end
