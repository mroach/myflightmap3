defmodule Myflightmap.TripFactory do
  @moduledoc """
  ExMachina factory for creating trips.
  """

  defmacro __using__(_opts) do
    quote do
      def trip_factory do
        %Myflightmap.Travel.Trip{
          user: build(:user),
          name: StreamData.string(:alphanumeric, min_length: 3) |> Enum.at(0),
          privacy: ~w[public private] |> Enum.random(),
          purpose: ~w[business pleasure] |> Enum.random()
        }
      end
    end
  end
end
