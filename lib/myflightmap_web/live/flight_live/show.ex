defmodule MyflightmapWeb.FlightLive.Show do
  use MyflightmapWeb, :live_view
  require Logger

  alias Myflightmap.Travel, as: T

  import MyflightmapWeb.Helpers.{AirlineHelpers, FlightHelpers}
  import MyflightmapWeb.{HeadingComponent}

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    flight = T.get_flight_with_assocs!(id)

    {:ok,
      socket
      |> assign(:flight, flight)
    }
  end

  def render(assigns) do
    ~H"""
      <div>
        <.heading_with_buttons>
          <:text_block>
            <%= @flight.airline.iata_code %><%= @flight.flight_code %>
          </:text_block>

          <:button>
            <.button phx-click={JS.navigate("/flights/#{@flight.id}/edit")}>
              <Heroicons.pencil_square class="mr-1.5 h-5 w-5 flex-shrink-0 text-gray-400" />
              Edit
            </.button>
          </:button>
        </.heading_with_buttons>

        <div class="p-4 bg-white rounded-lg md:p-8 dark:bg-gray-800">
          <dl class="grid grid-cols-2 gap-8 p-4 mx-auto max-w-screen-xl text-gray-900 sm:grid-cols-3 dark:text-white sm:p-8">
            <div class="flex flex-col justify-center items-center">
              <dt class="mb-2 text-3xl font-extrabold">
                <%= @flight.depart_airport.iata_code %>
              </dt>
              <dd class="font-light text-gray-500 dark:text-gray-400">
                <%= @flight.depart_airport.common_name %>
              </dd>
            </div>
            <div class="flex flex-col justify-center items-center">
              <dt class="mb-2 text-3xl font-extrabold">
                <%= @flight.arrive_airport.iata_code %>
              </dt>
              <dd class="font-light text-gray-500 dark:text-gray-400">
                <%= @flight.arrive_airport.common_name %>
              </dd>
            </div>
            <div class="flex flex-col justify-center items-center">
              <dt class="mb-2 text-3xl font-extrabold">
                <%= if airline_logo_available?(@flight.airline) do %>
                  <%= airline_logo(@flight.airline, "[35px]") %>
                <% else %>
                  <%= @flight.airline.iata_code %>
                <% end %>
              </dt>
              <dd class="font-light text-gray-500 dark:text-gray-400">
                <%= @flight.airline.name %>
              </dd>
            </div>
            <div class="flex flex-col justify-center items-center">
              <dt class="mb-2 text-3xl font-extrabold">
                <%= formatted_distance(@flight) %>
              </dt>
              <dd class="font-light text-gray-500 dark:text-gray-400">
                Distance
              </dd>
            </div>
            <div class="flex flex-col justify-center items-center">
              <dt class="mb-2 text-3xl font-extrabold">
                <%= formatted_duration(@flight) %>
              </dt>
              <dd class="font-light text-gray-500 dark:text-gray-400">
                Duration
              </dd>
            </div>
            <div class="flex flex-col justify-center items-center">
              <dt class="mb-2 text-3xl font-extrabold">
                <%= seat_class_name(@flight) %>
              </dt>
              <dd class="font-light text-gray-500 dark:text-gray-400">
                Seat class
              </dd>
            </div>
          </dl>
        </div>
        <div id="map-container" phx-update="ignore">
          <div id='map'
            style='width: 800px; height: 500px;'
            phx-hook="Mapbox"
            data-depart-coords={@flight.depart_airport.coordinates}
            data-arrive-coords={@flight.arrive_airport.coordinates}
          ></div>
        </div>
      </div>
    """
  end
end
