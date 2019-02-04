defmodule MyflightmapWeb.Helpers.AirportHelpers do
  alias Myflightmap.Transport.Airport

  @doc """
  Provide an unambiguous name for the airport. If a `metro_code` is present
  that means the airport is one of many in a city and we need to use a longer-form
  name of the airport. When no `metro_code` is present we can be reasonably sure
  there's only one airport in the city so using the city name is enough
  """
  def airport_name(%Airport{metro_code: nil, city: city}), do: city
  def airport_name(%Airport{common_name: name}), do: name
end
