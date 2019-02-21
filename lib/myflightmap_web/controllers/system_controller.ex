defmodule MyflightmapWeb.SystemController do
  use MyflightmapWeb, :controller

  def alive(conn, _params) do
    # run a query to ensure it works. will raise an exception if it fails
    Myflightmap.Repo.query!("SELECT VERSION();")

    text(conn, "OK")
  end
end
