defmodule Worldmate.ParseResultTest do
  use ExUnit.Case
  alias Worldmate.ParseResult

  test "success?/1" do
    assert true == ParseResult.success?(%ParseResult{status: "SUCCESS"})
    assert false == ParseResult.success?(%ParseResult{status: "NO_DATA"})
  end

  test "from_xml/1 with valid doc" do
    xmlstr = File.read!("./test/fixtures/worldmate-single.xml")

    assert {:ok, %ParseResult{}} = ParseResult.from_xml(xmlstr)
  end

  test "from_xml/1 with bogus doc" do
    assert {:error, _} = ParseResult.from_xml("junk")
  end
end
