defmodule Myflightmap.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Myflightmap.Repo,
      MyflightmapWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Myflightmap.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MyflightmapWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
