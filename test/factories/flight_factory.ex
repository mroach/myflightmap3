defmodule Myflightmap.FlightFactory do
  @moduledoc """
  ExMachina factory for creating flight.
  """

  import CommonValueFactory
  alias Myflightmap.Travel.Flight

  defmacro __using__(_opts) do
    quote do
      def flight_code, do: iata_code() |> flight_code
      def flight_code(iata_code), do: iata_code <> (1..9999 |> Enum.random |> Integer.to_string)

      def flight_factory do
        airline = insert(:airline)
        %Flight{
          user: build(:user),
          depart_airport: build(:airport),
          arrive_airport: build(:airport),
          airline: airline,
          flight_code: flight_code(airline.iata_code),
          depart_date: %Date{
            year: 1990..2019 |> Enum.random,
            month: 1..12 |> Enum.random,
            day: 1..28 |> Enum.random
          },
          depart_time: %Time{
            hour: 0..23 |> Enum.random,
            minute: 0..59 |> Enum.random,
            second: 0
          }
        }
      end

      def with_arrival_time(%{depart_date: date, depart_time: time} = flight) do
        # between 45 mins and 18 hours
        duration_seconds = Enum.random(45..1080) * 60
        flight
        |> Map.put(:arrive_date, date)
        |> Map.put(:arrive_time, Time.add(time, duration_seconds))
      end
    end
  end
end
