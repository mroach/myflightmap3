use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :myflightmap, MyflightmapWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
db_config =
  [
    username: System.get_env("DB_USER"),
    password: System.get_env("DB_PASS"),
    database: System.get_env("DB_NAME") || "myflightmap_test",
    hostname: System.get_env("DB_HOST") || "localhost",
    pool: Ecto.Adapters.SQL.Sandbox
  ]
  |> Enum.reject(fn {_, val} -> is_nil(val) end)

config :myflightmap, Myflightmap.Repo, db_config
