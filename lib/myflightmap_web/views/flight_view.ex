defmodule MyflightmapWeb.FlightView do
  use MyflightmapWeb, :view
  import MyflightmapWeb.Helpers.DateTimeHelpers
  import MyflightmapWeb.Helpers.FlightHelpers
  alias Myflightmap.{Transport, Travel}

  # Options for dropdowns on the flight form
  def airport_options, do: Transport.list_airport_options()
  def airline_options, do: Transport.list_airline_options()
  def aircraft_type_options, do: Transport.list_aircraft_type_options()
  def trip_options(user), do: Travel.list_trip_options(user)
  def seat_class_options, do: Transport.list_seat_class_options()
end
