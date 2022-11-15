defmodule MyflightmapWeb.TripLive.Show do
  use MyflightmapWeb, :live_view

  alias Myflightmap.Travel, as: T
  import MyflightmapWeb.{HeadingComponent}
  import MyflightmapWeb.FlightComponent, only: [flight_inline: 1]

  @impl true
  def mount(%{"id" => trip_id}, session, socket) do
    trip = T.get_trip!(trip_id)
    flights = T.list_flights_in_trip(trip_id)

    route_pairs =
      trip_id
      |> T.list_unique_route_pairs_in_trip()
      |> Enum.map(&(transform_route_pair(&1)))

    {:ok,
      socket
      |> assign(:trip, trip)
      |> assign(:flights, flights)
      |> assign(:route_pairs, route_pairs)
    }
  end

  def trip_duration_days(%{start_date: nil, end_date: nil}), do: nil
  def trip_duration_days(%{start_date: start_date, end_date: end_date}) do
    Date.diff(end_date, start_date)
  end
  def show_trip_duration?(%{start_date: nil}), do: false
  def show_trip_duration?(%{end_date: nil}), do: false
  def show_trip_duration?(_), do: true

  def transform_route_pair(%{airport_1: ap1, airport_2: ap2, count: c}) do
    transform_airport = fn ap ->
      %{
        iata_code: ap.iata_code,
        name: ap.common_name,
        latitude: ap.coordinates.x,
        longitude: ap.coordinates.y,
      }
    end

    %{
      airport_1: transform_airport.(ap1),
      airport_2: transform_airport.(ap2),
      count: c
    }
  end

  def render(assigns) do
    ~H"""
      <div>
        <.heading_with_buttons text={@trip.name}>
          <:button>
            <.button phx-click={JS.navigate("/trips/#{@trip.id}/edit")}>
              <Heroicons.pencil_square class="mr-1.5 h-5 w-5 flex-shrink-0 text-gray-400" />
              Edit
            </.button>
          </:button>

          <:button>
            <.button phx-click={JS.navigate("/flights/new?trip_id=#{@trip.id}")}>
              <Heroicons.plus_circle class="mr-1.5 h-5 w-5 flex-shrink-0 text-gray-400" />
              Add Flight
            </.button>
          </:button>

          <:sub_item>
            <Heroicons.paper_airplane class="mr-1.5 h-5 w-5 flex-shrink-0 text-gray-400" />
            <%= "#{length(@flights)} Flights" %>
          </:sub_item>

          <:sub_item :if={show_trip_duration?(@trip)}>
            <Heroicons.calendar_days class="mr-1.5 h-5 w-5 flex-shrink-0 text-gray-400" />
            <%= trip_duration_days(@trip) %> day trip
          </:sub_item>

          <:sub_item>
            <Heroicons.user_circle class="mr-1.5 h-5 w-5 flex-shrink-0 text-gray-400" />
            <%= @trip.user.name %>
          </:sub_item>

        </.heading_with_buttons>

        <%= if length(@flights) == 0 do %>
          <p class="text-2 text-gray-900 dark:text-white">No flights yet in this trip</p>
        <% else %>
          <%= for flight <- @flights do %>
            <.flight_inline flight={flight} />
          <% end %>

        <% end %>

        <div id="map-container" phx-update="ignore">
          <div style='width: 800px; height: 500px;' id="map" phx-hook="MapboxRoutePairs">
            <script data-purpose="route-pairs" type="application/json">
              <%= raw(Jason.encode!(@route_pairs)) %>
            </script>
          </div>
        </div>
      </div>
    """
  end
end
