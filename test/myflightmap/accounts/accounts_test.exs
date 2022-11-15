defmodule Myflightmap.AccountsTest do
  use Myflightmap.DataCase

  alias Myflightmap.Accounts
  import Myflightmap.Factory

  describe "users" do
    alias Myflightmap.Accounts.User

    @invalid_attrs %{name: nil, username: nil}

    test "list_users/0 returns all users" do
      user = insert(:user)
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user) |> Repo.preload(:credential)
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = _user} = Accounts.create_user(params_for(:user))
    end

    test "create_user/1 with valid data creates a user and assigns trip email id" do
      {:ok, %User{} = user} = Accounts.create_user(params_for(:user))
      refute is_nil(user.trip_email_id)
    end

    test "create_user/1 does not override provided trip email id" do
      trip_email_id = "asdqwe123"

      {:ok, %User{} = user} =
        Accounts.create_user(params_for(:user, trip_email_id: trip_email_id))

      assert user.trip_email_id == trip_email_id
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      update_attrs = %{name: "new name"}
      assert {:ok, user} = Accounts.update_user(user, update_attrs)
      assert %User{} = user
      assert user.name == "new name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user) |> Repo.preload(:credential)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
