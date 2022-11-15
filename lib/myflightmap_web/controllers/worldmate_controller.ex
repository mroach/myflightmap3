defmodule MyflightmapWeb.WorldmateController do
  use MyflightmapWeb, :controller
  require Logger

  def receive(conn, _params) do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)

    type = conn |> get_req_header("content-type")
    Logger.info("Received Worldmate response (#{type}):\n#{body}")

    text(conn, "OK")
  end
end
