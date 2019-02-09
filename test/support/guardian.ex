defmodule Myflightmap.Mock.Guardian do
  use Guardian, otp_app: :myflightmap

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    {id, _} = Integer.parse(claims["sub"])
    user = %Myflightmap.Accounts.User{id: id, username: "Tester"}
    {:ok, user}
  end
end
