# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# General application configuration
config :myflightmap,
  ecto_repos: [Myflightmap.Repo]

config :myflightmap, Myflightmap.Repo,
  migration_primary_key: [
    type: :binary_id,
    default: {:fragment, "gen_random_uuid()"}
  ],
  migration_timestamps: [
    default: {:fragment, "NOW()"}
  ]

# Configures the endpoint
config :myflightmap, MyflightmapWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CMzrEz4+CMGzENGalD8xyRPCv25m7h1chEtLORG7dQz7gzNhD5YzKSojRyDl9LLQ",
  render_errors: [view: MyflightmapWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MyflightmapWeb.PubSub,
  live_view: [signing_salt: "x9OVow7tR0Do05Dun6pA1TWiIwqJ1l63"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :phoenix, :json_library, Jason

config :tesla, adapter: Tesla.Adapter.Hackney

config :myflightmap, Myflightmap.Travel.WorldmateTripImporter,
  valid_domains: ~w(trips.myflightmap.com)

config :myflightmap, Myflightmap.UserEmailId, salt: "saltysalt"

config :myflightmap, Myflightmap.Auth.Guardian,
  issuer: "myflightmap",
  secret_key: "nnMP2E/21SwWTWBQnDDhPfW7q4TddFE17sBhpLOLJ28U5V0znMs7Bzkh76Hd5Ft5"

config :myflightmap, Myflightmap.Auth.AccessPipeline,
  module: Myflightmap.Auth.Guardian,
  error_handler: Myflightmap.Auth.ErrorHandler

config :tailwind,
  version: "3.2.1",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2019 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Mix.Project.deps_path()}
  ]

# In dev env, use `mix test.watch` to automatically run tests and credo
# every time a file is saved. Faster TDD response cycle.
if Mix.env() == :dev do
  config :mix_test_watch,
    tasks: [
      "test",
      "credo --strict"
    ]
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
