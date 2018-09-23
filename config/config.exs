# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :myflightmap,
  ecto_repos: [Myflightmap.Repo]

# Configures the endpoint
config :myflightmap, MyflightmapWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CMzrEz4+CMGzENGalD8xyRPCv25m7h1chEtLORG7dQz7gzNhD5YzKSojRyDl9LLQ",
  render_errors: [view: MyflightmapWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Myflightmap.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
