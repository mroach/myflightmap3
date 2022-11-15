defmodule Worldmate.ItineraryParserText do
  use ExUnit.Case
  alias Worldmate.ItineraryParser
  alias Worldmate.{Aircraft, Airport, Flight, Movement}

  doctest Worldmate.ItineraryParser

  setup do
    xmlstr = File.read!("./test/fixtures/worldmate-single.xml")

    single =
      File.read!("./test/fixtures/worldmate-single.xml")
      |> ItineraryParser.parse_xml!()

    multi_codeshare =
      File.read!("./test/fixtures/worldmate-multi-codeshare.xml")
      |> ItineraryParser.parse_xml!()

    {:ok,
     [
       single: single,
       multi_codeshare: multi_codeshare,
       xmlstr: xmlstr
     ]}
  end

  test "read/1 loads an xml string", %{xmlstr: str} do
    assert {:ok, _} = str |> ItineraryParser.parse_xml()
  end

  test "read!/1 loads an xml string", %{xmlstr: str} do
    assert x = str |> ItineraryParser.parse_xml!()
    assert is_tuple(x)
  end

  test "read/1 with invalid root tag" do
    assert {:ok, nil} == ItineraryParser.parse_xml("<bogus></bogus>")
  end

  test "read/1 with invalid xml" do
    assert {:error, _} = ItineraryParser.parse_xml("bogus")
  end

  test "status/1 finds SUCCESS with success doc", %{single: doc} do
    assert "SUCCESS" == doc |> ItineraryParser.status()
  end

  test "request_id/1 finds the ID from the doc", %{single: doc} do
    assert "176728568" == doc |> ItineraryParser.request_id()
  end

  test "flights/1 returns flight data", %{multi_codeshare: doc} do
    result = doc |> ItineraryParser.flights()
    assert 5 == Enum.count(result)
  end

  test "flights/1 with codeshare" do
    # The real flight is by AF, codeshared as DL
    result =
      ~s"""
      <ns2:worldmate-parsing-result>
        <items>
          <flight>
            <details number="8487" airline-code="DL"/>
            <operated-by number="1611" airline-code="AF"/>
            <aircraft code="748" name="Boeing 747-8 Passenger" />
          </flight>
        </items>
      </ns2:worldmate-parsing-result>
      """
      |> ItineraryParser.parse_xml!()
      |> ItineraryParser.flights()
      |> Enum.at(0)

    assert %Flight{flight_code: %{airline_code: "AF", flight_number: "1611"}} = result
    assert %Flight{codeshare: %{airline_code: "DL", flight_number: "8487"}} = result
    assert %Flight{aircraft: %Aircraft{code: "748", description: "Boeing 747-8 Passenger"}}
  end

  test "flights/1 without codeshare" do
    result =
      ~s"""
      <ns2:worldmate-parsing-result>
        <items>
          <flight>
            <details number="26" airline-code="SQ"/>
          </flight>
        </items>
      </ns2:worldmate-parsing-result>
      """
      |> ItineraryParser.parse_xml!()
      |> ItineraryParser.flights()
      |> Enum.at(0)

    assert %Flight{flight_code: %{airline_code: "SQ", flight_number: "26"}} = result
    assert %Flight{codeshare: nil} = result
  end

  test "flights/1 from single flight sample", %{single: doc} do
    flight = doc |> ItineraryParser.flights() |> Enum.at(0)

    assert %Flight{
             departure: %Movement{
               airport: %Airport{iata_code: "FRA", name: "Frankfurt International Airport"},
               terminal: "1",
               gate: nil
             },
             arrival: %Movement{
               airport: %Airport{iata_code: "JFK", name: "John F. Kennedy International Airport"},
               terminal: "4",
               gate: nil
             },
             seat: "61D",
             seat_class: "Economy  (X)",
             duration_minutes: 535,
             confirmation_number: "ABC123",
             flight_code: %{airline_code: "SQ", flight_number: "26"}
           } = flight
  end

  test "headers/1", %{single: doc} do
    result = doc |> ItineraryParser.headers()
    assert %{"subject" => "Fwd: Your seat selection confirmation ABC123"} = result
    assert %{"from" => "Michael Roach <mroach@mroach.com>"} = result
  end

  test "to_parse_result/1 with full response generates a nice map", %{single: doc} do
    result = doc |> ItineraryParser.to_parse_result()
    assert %{status: _, headers: _, flights: _} = result
  end
end
