defmodule MyflightmapWeb.Router do
  use MyflightmapWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MyflightmapWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :maybe_auth do
    plug Myflightmap.Auth.AccessPipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MyflightmapWeb do
    pipe_through [:browser, :maybe_auth]

    get "/", HomeController, :index

    get "/session/new", SessionController, :new
    post "/session", SessionController, :create
    delete "/session", SessionController, :delete

    resources "/users", UserController, only: [:new, :create]
  end

  scope "/", MyflightmapWeb do
    pipe_through [:browser, :maybe_auth, :ensure_auth]

    live "/airlines", AirlineLive.Index
    live "/airports", AirportLive.Index

    resources "/aircraft_types", AircraftTypeController

    live "/flights", FlightLive.Index
    live "/flights/new", FlightLive.Edit
    live "/flights/:id", FlightLive.Show
    live "/flights/:id/edit", FlightLive.Edit

    live "/trips", TripLive.Index
    live "/trips/new", TripLive.Edit
    live "/trips/:id", TripLive.Show
    live "/trips/:id/edit", TripLive.Edit
  end

  scope "/system", MyflightmapWeb do
    get "/alive", SystemController, :alive
    get "/stats", SystemController, :stats
  end

  scope "/vendor", MyflightmapWeb do
    post "/worldmate/receive", WorldmateController, :receive
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MyflightmapWeb.Telemetry
    end
  end
end
