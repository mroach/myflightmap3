defmodule Myflightmap.AirlineFactory do
  @moduledoc """
  ExMachina factory for creating airlines.
  """

  defmacro __using__(_opts) do
    quote do
      def iata_code do
        [?A..?Z, ?0..?9]
        |> Enum.concat
        |> StreamData.string(min_length: 2, max_length: 2)
        |> Enum.at(0)
      end

      def icao_code do
        ?A..?Z
        |> StreamData.string(min_length: 3, max_length: 3)
        |> Enum.at(0)
      end

      def country_code do
        Countries.all |> Enum.random |> Map.get(:alpha2)
      end

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
