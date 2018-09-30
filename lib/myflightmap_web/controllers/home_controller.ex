defmodule MyflightmapWeb.HomeController do
  use MyflightmapWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
