defmodule Myflightmap.AirportFactory do
  @moduledoc """
  ExMachina factory for creating airports.
  """

  import CommonValueFactory

  defmacro __using__(_opts) do
    quote do
      # Generate random coordinates.
      # Latitude limits are -90 to +90
      # Longitude limits are -180 to +180
      def coordinates do
        gen = fn lim -> :rand.uniform * lim * Enum.random([1, -1]) end
        Point.new(gen.(90), gen.(180))
      end

      def airport_factory do
        %Myflightmap.Transport.Airport{
          common_name: StreamData.string(:alphanumeric, min_length: 3) |> Enum.at(0),
          iata_code: iata_code(),
          icao_code: icao_code(),
          country: country_code(),
          timezone: timezone(),
          coordinates: coordinates()
        }
      end
    end
  end
end
