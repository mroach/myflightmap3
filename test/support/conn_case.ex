defmodule MyflightmapWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      alias MyflightmapWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint MyflightmapWeb.Endpoint

      import MyflightmapWeb.ConnCase
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Myflightmap.Repo)
    unless tags[:async] do
      Sandbox.mode(Myflightmap.Repo, {:shared, self()})
    end

    conn = Phoenix.ConnTest.build_conn()
    authed_conn = guardian_login(conn)
    {:ok, conn: Phoenix.ConnTest.build_conn(), authed_conn: authed_conn}
  end

  def guardian_login(conn) do
    guardian_login(conn, %Myflightmap.Accounts.User{id: 1})
  end
  def guardian_login(conn, user) do
    Myflightmap.Auth.Guardian.Plug.sign_in(conn, user)
  end
end
