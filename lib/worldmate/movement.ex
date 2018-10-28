defmodule Worldmate.Movement do
  @moduledoc """
  A movement is one end of a `Flight`. The departure or arrival.
  """

  defstruct airport: nil,
            local_time: nil,
            utc_time: nil,
            terminal: nil,
            gate: nil
end
