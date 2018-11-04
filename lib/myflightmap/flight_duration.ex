defmodule Myflightmap.FlightDuration do
  @moduledoc """
  Helper for calculating flight duration based on changeset data.
  This is of course timezone aware using the airports' timezones
  """

  import Ecto.Changeset

  def from_changeset(%Ecto.Changeset{} = changeset) do
    with %DateTime{} = depart_at <- movement_time(changeset, "depart"),
         %DateTime{} = arrive_at <- movement_time(changeset, "arrive")
      do
        Timex.diff(arrive_at, depart_at, :minutes)
      end
  end

  def movement_time(changeset, movement) do
    with %Date{} = date <- get_field(changeset, :"#{movement}_date"),
         %Time{} = time <- get_field(changeset, :"#{movement}_time"),
         {:ok, datetime} = _ <- NaiveDateTime.new(date, time)
      do
        timezone = airport_timezone(changeset, :"#{movement}_airport_id")
        Timex.to_datetime(datetime, timezone)
      end
  end

  defp airport_timezone(changeset, id_field) do
    changeset
    |> get_field(id_field)
    |> Myflightmap.Transport.get_airport!
    |> (fn airport -> airport.timezone end).()
  end
end
