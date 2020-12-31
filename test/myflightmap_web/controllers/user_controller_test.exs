defmodule MyflightmapWeb.UserControllerTest do
  use MyflightmapWeb.ConnCase

  import Myflightmap.Factory

  @invalid_attrs %{name: nil, username: nil}

  describe "index" do
    test "lists all users", %{authed_conn: conn} do
      res = get conn, Routes.user_path(conn, :index)
      assert html_response(res, 200) =~ "Users"
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get conn, Routes.user_path(conn, :new)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{authed_conn: conn} do
      user_params = params_for(:user)
      res = post conn, Routes.user_path(conn, :create), user: user_params

      assert %{id: id} = redirected_params(res)
      assert redirected_to(res) == Routes.user_path(conn, :show, id)

      conn = get conn, Routes.user_path(conn, :show, id)
      assert html_response(conn, 200) =~ String.downcase(user_params.username)
    end

    test "renders errors when data is invalid", %{authed_conn: conn} do
      conn = post conn, Routes.user_path(conn, :create), user: @invalid_attrs
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{authed_conn: conn, user: user} do
      conn = get conn, Routes.user_path(conn, :edit, user)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{authed_conn: conn, user: user} do
      update_attrs = %{username: "new name"}
      res = put conn, Routes.user_path(conn, :update, user), user: update_attrs
      assert redirected_to(res) == Routes.user_path(conn, :show, user)

      res = get conn, Routes.user_path(conn, :show, user)
      assert html_response(res, 200) =~ "new name"
    end

    test "renders errors when data is invalid", %{authed_conn: conn, user: user} do
      conn = put conn, Routes.user_path(conn, :update, user), user: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{authed_conn: conn, user: user} do
      res = delete conn, Routes.user_path(conn, :delete, user)
      assert redirected_to(res) == Routes.user_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, Routes.user_path(conn, :show, user)
      end
    end
  end

  defp create_user(_) do
    user = insert(:user)
    {:ok, user: user}
  end
end
