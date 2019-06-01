defmodule MyflightmapWeb.Router do
  use MyflightmapWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
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

    resources "/aircraft_types", AircraftTypeController
    resources "/airlines", AirlineController
    resources "/airports", AirportController

    resources "/users", UserController, only: [:new, :create]
  end

  scope "/", MyflightmapWeb do
    pipe_through [:browser, :maybe_auth, :ensure_auth]

    resources "/flights", FlightController
    resources "/users", UserController, except: [:new, :create]
    resources "/trips", TripController
  end

  scope "/system", MyflightmapWeb do
    get "/alive", SystemController, :alive
    get "/stats", SystemController, :stats
  end

  scope "/vendor", MyflightmapWeb do
    post "/worldmate/receive", WorldmateController, :receive
  end
end
