defmodule Myflightmap.AuthTest do
  use Myflightmap.DataCase

  alias Myflightmap.{Accounts, Auth}

  doctest Auth

  test "authenticate_by_email/2 with a valid username and password" do
    email = "test@example.org"
    pass = "letmein"

    {:ok, %{id: user_id}} =
      Accounts.register_user(%{
        username: "tester",
        credential: %{
          email: email,
          password: pass,
          password_confirmation: pass
        }
      })

    assert {:ok, %{id: ^user_id}} = Auth.authenticate_by_email(email, pass)
  end

  test "authenticate_by_email/2 with a valid username and invalid password" do
    email = "test@example.org"
    pass = "letmein"

    {:ok, _user} =
      Accounts.register_user(%{
        username: "tester",
        credential: %{
          email: email,
          password: pass,
          password_confirmation: pass
        }
      })

    assert {:error, :not_accepted} == Auth.authenticate_by_email(email, "bogus")
  end

  test "authenticate_by_email/2 when the user doesn't exist" do
    assert {:error, :not_found} == Auth.authenticate_by_email("bogus@example.net", "")
  end
end
