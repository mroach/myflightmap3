defmodule WorldmateTest do
  use ExUnit.Case
  alias Worldmate.ParseResult

  doctest Worldmate

  test "parsing_result/1 with valid response" do
    xmlstr = File.read!("./test/fixtures/worldmate-single.xml")

    result = Worldmate.parse_xml_itinerary!(xmlstr)

    assert %ParseResult{
      flights: [%Worldmate.Flight{}], headers: _, status: _} = result
  end
end
