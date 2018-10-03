defmodule Myflightmap.UserFactory do
  @moduledoc """
  ExMachina factory for creating users.
  """

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %Myflightmap.Accounts.User{
          username: StreamData.string(:alphanumeric, min_length: 3) |> Enum.at(0),
          name: StreamData.string(:alphanumeric, min_length: 5) |> Enum.at(0)
        }
      end
    end
  end
end
