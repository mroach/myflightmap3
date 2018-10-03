defmodule PointTest do
  use ExUnit.Case

  doctest Point

  test "cast/1 with tuple" do
    assert {:ok, %Point{}} = Point.cast({1.23, 4.0})
  end
end
