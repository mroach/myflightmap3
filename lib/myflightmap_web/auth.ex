defmodule MyflightmapWeb.Auth do
  def user_from_session(session) do
    %{"guardian_default_token" => token} = session
    {:ok, claims} = Myflightmap.Auth.Guardian.decode_and_verify(token)

    Myflightmap.Auth.Guardian.resource_from_claims(claims)
  end
end
