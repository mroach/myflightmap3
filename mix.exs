defmodule Myflightmap.Mixfile do
  use Mix.Project

  def project do
    [
      app: :myflightmap,
      version: "0.0.1",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
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
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:ecto_sql, "~> 3.5"},
      {:jason, "~> 1.2"},
      {:phoenix, "~> 1.5.7"},
      {:phoenix_ecto, "~> 4.2"},
      {:phoenix_html, "~> 2.14"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      {:countries, "~> 1.6"},
      # Date/time parsing and formatting. Timezone conversions.
      {:timex, "~> 3.6"},
      {:hashids, "~> 2.0"},

      # XML parser. Needed for handling Worldmate trip parsing responses
      {:sweet_xml, "~> 0.7.0"},
      {:distillery, "~> 2.0"},
      {:hackney, "~> 1.14"},
      {:tesla, "~> 1.4"},
      {:nimble_csv, "~> 0.3"},

      # Authentication
      {:bcrypt_elixir, "~> 2.0"},
      {:guardian, "~> 1.0"},

      # limited envs:
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:ex_machina, "~> 2.2", only: :test},
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
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
