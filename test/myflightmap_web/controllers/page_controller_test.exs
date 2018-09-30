defmodule MyflightmapWeb.PageControllerTest do
  use MyflightmapWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "My Flight Map"
  end
end
