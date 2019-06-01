defmodule MyflightmapWeb.WorldmateControllerTest do
  use MyflightmapWeb.ConnCase

  test "/vendor/worldmate/receive", %{conn: conn} do
    raw_xml = File.read!("./test/fixtures/worldmate-single.xml")

    conn =
      conn
      |> put_req_header("content-type", "text/plain;charset=utf-8")
      |> post("/vendor/worldmate/receive", raw_xml)

    assert conn.status == 200
    assert conn.resp_body == "OK"
  end
end
