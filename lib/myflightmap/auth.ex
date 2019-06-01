defmodule Myflightmap.Auth do
  @moduledoc false

  alias Comeonin.Bcrypt
  alias Myflightmap.Accounts
  alias Myflightmap.Accounts.User

  def authenticate_by_email(email, pass) do
    email
    |> Accounts.get_user_by_email()
    |> authenticate_with_password(pass)
  end

  def authenticate_with_password(%User{} = user, pass) do
    if Bcrypt.checkpw(pass, user.credential.password_hash) do
      {:ok, user}
    else
      Bcrypt.dummy_checkpw()
      {:error, :not_accepted}
    end
  end

  def authenticate_with_password(_, _) do
    {:error, :not_found}
  end
end
