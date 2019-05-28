defmodule Worldmate do
  alias Worldmate.ItineraryParser

  @moduledoc """
  Consumer of parsed itineraries from Worldmate.
  """

  @doc """
  Converts a [Worldmate parsing result](https://developers.worldmate.com/documentation.php#_Toc317625927)
  to a simple `ParseResult` that can be easily consumed.
  """
  def parse_xml_itinerary!(xmlstr) do
    xmlstr
    |> ItineraryParser.parse_xml!
    |> ItineraryParser.to_parse_result
  end
end
