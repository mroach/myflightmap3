defmodule Point do
  @moduledoc """
  Represents any point with x and y coordinates.
  In this app it'll be used for storing coordinates, so further validiation
  should be added to constrain the latitude and longitude (x and y).
  """

  use Ecto.Type

  @enforce_keys [:x, :y]

  defstruct [:x, :y]

  @type t :: %__MODULE__{
          x: float,
          y: float
        }

  def type, do: __MODULE__

  def cast(val) when is_binary(val) do
    case Point.parse(val) do
      %Point{} = p -> {:ok, p}
      _ -> :error
    end
  end

  def cast(tuple) when is_tuple(tuple) do
    case Point.new(tuple) do
      %Point{} = p -> {:ok, p}
      _ -> :error
    end
  end

  def cast(%Point{} = p), do: {:ok, p}
  def cast(_), do: :error

  def load(%Point{} = p), do: {:ok, p}
  def load(%Postgrex.Point{} = p), do: {:ok, new(p.x, p.y)}
  def load(_), do: :error

  def dump(%Point{} = p), do: {:ok, %Postgrex.Point{x: p.x, y: p.y}}
  def dump(_), do: :error

  @doc """
  Initialise a new Point

  Example:
      iex> Point.new("1.2343", "4.0")
      %Point{x: 1.2343, y: 4.0}

      iex> Point.new(1.2343, 4.0)
      %Point{x: 1.2343, y: 4.0}

      iex> Point.new(1.2343, 4.0)
      %Point{x: 1.2343, y: 4.0}

      iex> {1.2343, 4.0} |> Point.new
      %Point{x: 1.2343, y: 4.0}

      iex> Point.new("a", "b")
      :error
  """
  def new(x, y) when is_binary(x) and is_binary(y) do
    with {x_val, _rem} <- Float.parse(x),
         {y_val, _rem} <- Float.parse(y) do
      new(x_val, y_val)
    else
      err -> err
    end
  end

  def new(x, y) when is_float(x) and is_float(y), do: %Point{x: x, y: y}
  def new(_, _), do: :error

  def new({x, y}) when is_float(x) and is_float(y), do: new(x, y)

  @doc """
  Parse a string with points into a Point

  Examples:
      iex> Point.parse("1.2343, 4.0")
      %Point{x: 1.2343, y: 4.0}
  """
  def parse(str) when is_binary(str) do
    with [x, y] <- String.split(str, ~r/[,\s]+/),
         %Point{} = p <- Point.new(x, y) do
      p
    else
      err -> {:error, err}
    end
  end

  def to_s(%Point{x: x, y: y}), do: "#{x}, #{y}"
end

defimpl Phoenix.HTML.Safe, for: Point do
  def to_iodata(%Point{} = p), do: p |> Point.to_s() |> Plug.HTML.html_escape()
end
