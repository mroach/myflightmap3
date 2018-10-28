defmodule Worldmate.Airport do
  @moduledoc """
  An airport found in a parsing result.
  """

  defstruct iata_code: nil,
            name: nil,
            latitude: nil,
            longitude: nil
end
