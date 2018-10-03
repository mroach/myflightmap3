defmodule Myflightmap.AirlineFactory do
  @moduledoc """
  ExMachina factory for creating airlines.
  """

  import CommonValueFactory

  defmacro __using__(_opts) do
    quote do
      def alliance do
        ~w[staralliance oneworld skyteam] |> Enum.random
      end

      def airline_factory do
        %Myflightmap.Transport.Airline{
          name: StreamData.string(:alphanumeric, min_length: 3) |> Enum.at(0),
          iata_code: iata_code(),
          icao_code: icao_code(),
          country: country_code(),
          alliance: alliance()
        }
      end
    end
  end
end
