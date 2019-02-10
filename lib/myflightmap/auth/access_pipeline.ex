defmodule Myflightmap.Auth.AccessPipeline do
  use Guardian.Plug.Pipeline, otp_app: :myflightmap

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.LoadResource, allow_blank: true
  plug :set_user

  defp set_user(conn, _) do
    user = Myflightmap.Auth.Guardian.Plug.current_resource(conn)
    assign(conn, :current_user, user)
  end
end
