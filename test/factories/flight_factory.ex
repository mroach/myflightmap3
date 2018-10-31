defmodule Myflightmap.FlightFactory do
  @moduledoc """
  ExMachina factory for creating flight.
  """

  defmacro __using__(_opts) do
    quote do
      def flight_factory do
        %Myflightmap.Travel.Flight{
          depart_airport_id: insert(:airport).id,
          arrive_airport_id: insert(:airport).id,
          airline_id: insert(:airline).id,
          depart_date: %Date{
            year: 1990..2019 |> Enum.random,
            month: 1..12 |> Enum.random,
            day: 1..28 |> Enum.random
          }
        }
      end
    end
  end
end
