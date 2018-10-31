defmodule MyflightmapWeb.AuthController do
  use MyflightmapWeb, :controller
  alias Ueberauth.Strategy.Helpers

  plug Ueberauth

  def request(conn, _params) do
    conn
    |> render("request.html", callback_url)
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Bye!")
    |> configure_session(drop: true)
    |> redirect(to: home_path(@conn, :index))
  end

  def identity_callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    case validate_password(auth.credentials) do
      :ok ->
        user = %{id: auth.uid, name: name_from_auth(auth)}
        conn
        |> put_flash(:info, "Welcome")
        |> put_session(:current_user, user)
        |> redirect(to: home_path(@conn, :index))
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: home_path(@conn, :index))
      end
    end
  end
end