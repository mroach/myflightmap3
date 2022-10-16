defmodule Myflightmap.Mixfile do
  use Mix.Project

  def project do
    [
      app: :myflightmap,
      version: "0.0.1",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Myflightmap.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "test/factories"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6.14"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:phoenix_live_view, "~> 0.17.5"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},

      # Date/time parsing and formatting. Timezone conversions.
      {:timex, "~> 3.6"},
      {:hashids, "~> 2.0"},

      # ISO List of countries
      {:countries, "~> 1.6"},

      # XML parser. Needed for handling Worldmate trip parsing responses
      {:sweet_xml, "~> 0.6.5"},
      {:hackney, "~> 1.14"},
      {:tesla, "~> 1.4"},
      {:nimble_csv, "~> 0.3"},

      # Authentication
      {:bcrypt_elixir, "~> 3.0"},
      {:guardian, "~> 2.3"},

      # limited envs:
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:dart_sass, "~> 0.5", runtime: Mix.env() == :dev},
      {:bulma, "~> 0.9.3", runtime: Mix.env() == :dev},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:ex_machina, "~> 2.7", only: :test},
      {:stream_data, "~> 0.4", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "assets.deploy": [
        "esbuild default --minify",
        "sass default --no-source-map --style=compressed",
        "phx.digest"
      ]
    ]
  end
end
