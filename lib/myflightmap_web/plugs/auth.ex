defmodule MyflightmapWeb.Auth do
  @moduledoc """
  Plug to handle user authentication
  """

  import Plug.Conn

  alias Myflightmap.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    # Currently just faking a user until auth is implemented
    user = case Accounts.list_users() do
      [user | _tail] -> user
      _ -> Myflightmap.Factory.insert(:user)
    end
    assign(conn, :current_user, user)
  end
end
