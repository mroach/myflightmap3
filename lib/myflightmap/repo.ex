defmodule Myflightmap.Repo do
  use Ecto.Repo,
    otp_app: :myflightmap,
    adapter: Ecto.Adapters.Postgres
end
