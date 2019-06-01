defmodule MyflightmapWeb.SessionController do
  use MyflightmapWeb, :controller

  alias Myflightmap.Auth

  import Myflightmap.Auth.Guardian.Plug, only: [sign_in: 2, sign_out: 1]

  def new(conn, params) do
    conn
    |> assign(:return_to, params["return_to"])
    |> render("new.html")
  end

  def create(conn, %{"session" => %{"email" => email, "password" => pass}} = params) do
    case Auth.authenticate_by_email(email, pass) do
      {:ok, user} ->
        conn
        |> sign_in(user)
        |> assign(:current_user, user)
        |> put_flash(:success, "Welcome")
        |> redirect_to_destination(params)
      {:error, reason} ->
        conn
        |> put_flash(:error, "Login failed: #{ reason }")
        |> redirect(to: session_path(conn, :new))
    end
  end

  def delete(conn, _) do
    conn
    |> sign_out()
    |> put_flash(:info, "Ciao!")
    |> redirect(to: home_path(conn, :index))
  end

  defp redirect_to_destination(conn, %{"session" => %{"return_to" => path}})
    when byte_size(path) > 0 do
    redirect(conn, to: path)
  end
  defp redirect_to_destination(conn, _) do
    redirect(conn, to: home_path(conn, :index))
  end
end
