defmodule MyflightmapWeb.HomeController do
  use MyflightmapWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:user, get_session(conn, :current_user))
    |> render("index.html")
  end
end
