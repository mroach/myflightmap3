defmodule Myflightmap.AircraftTypeFactory do
  @moduledoc """
  ExMachina factory for creating aircraft types.
  """

  import CommonValueFactory

  defmacro __using__(_opts) do
    quote do
      def manufacturer_code do
        ~w[BOEING AIRBUS EMBRAER BAE ATR] |> Enum.random()
      end

      def engine_type do
        ["Jet", "Turboprop/Turboshaft", "Piston"] |> Enum.random()
      end

      def aircraft_type_factory do
        %Myflightmap.Transport.AircraftType{
          description: StreamData.string(:alphanumeric, min_length: 3) |> Enum.at(0),
          iata_code: iata_code(),
          icao_code: icao_code(),
          engine_type: engine_type(),
          engine_count: Enum.random(2..4),
          manufacturer_code: manufacturer_code()
        }
      end
    end
  end
end
