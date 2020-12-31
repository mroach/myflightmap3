defmodule Myflightmap.Auth.ErrorHandler do
  @moduledoc false

  import Plug.Conn
  alias MyflightmapWeb.Router.Helpers, as: Routes
  alias Phoenix.Controller

  def auth_error(conn, {:unauthenticated, _reason}, _opts) do
    requested = Controller.current_path(conn)
    conn
    |> Controller.put_flash(:error, "Login required")
    |> Controller.redirect(to: Routes.session_path(conn, :new, return_to: requested))
    |> halt()
  end
end
