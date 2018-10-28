defmodule Worldmate.Flight do
  @moduledoc """
  An flight found in a parsing result. The `departure` and `arrival` are mapped
  as a `Movement` which will contain airport information and times
  """

  defstruct confirmation_number: nil,
            operator: nil,
            flight_code: nil,
            codeshare: nil,
            departure: nil,
            arrival: nil,
            aircraft: nil,
            duration_minutes: nil,
            distance_miles: nil,
            seat_class: nil,
            seat: nil
end
