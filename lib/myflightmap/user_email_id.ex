defmodule Myflightmap.UserEmailId do
  @moduledoc """
  Designed for compatibility with the ID generator from the previous
  version of myflightmap. Uses the same min length and alphabet.

  The salt is configured with application config:

      config :myflightmap, Myflightmap.UserEmailId,
        salt: "saltysalt"

  """

  @alphabet "ABCDFGHKJLMNPQRSTXYZ123456789"
  @min_len 6

  @doc """
  Encode a user's ID into a string using hash IDs

  ### Example
      iex> Myflightmap.UserEmailId.encode(1)
      "14LMGP"
  """
  def encode(data), do: Hashids.encode(coder(), data)

  @doc """
  Decode data that was originally encoded with `encode/1`.

  ### Example
      iex> Myflightmap.UserEmailId.decode("14LMGP")
      1
  """
  def decode(data) do
    case Hashids.decode(coder(), data) do
      {:ok, [n | _]} -> n
      _ -> nil
    end
  end

  defp coder do
    Hashids.new(alphabet: @alphabet, min_len: @min_len, salt: salt())
  end

  defp salt do
    :myflightmap
    |> Application.get_env(__MODULE__)
    |> Keyword.fetch!(:salt)
  end
end
