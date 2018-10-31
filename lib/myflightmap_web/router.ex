defmodule MyflightmapWeb.Router do
  use MyflightmapWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug MyflightmapWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MyflightmapWeb do
    pipe_through :browser # Use the default browser stack

    get "/", HomeController, :index

    resources "/aircraft_types", AircraftTypeController
    resources "/airlines", AirlineController
    resources "/airports", AirportController
    resources "/flights", FlightController
    resources "/users", UserController
    resources "/trips", TripController
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyflightmapWeb do
  #   pipe_through :api
  # end
end
