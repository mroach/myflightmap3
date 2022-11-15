defmodule MyflightmapWeb.TripLive.Index do
  use MyflightmapWeb, :live_view
  require Logger

  alias Myflightmap.Travel, as: T
  import MyflightmapWeb.Helpers.{AirlineHelpers, DateTimeHelpers, FlightHelpers}
  import MyflightmapWeb.{HeadingComponent}
  import MyflightmapWeb.FlightComponent, only: [flight_card: 1]

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = MyflightmapWeb.Auth.user_from_session(session)

    socket =
      socket
      |> load_trips(user.id)

    {:ok, socket}
  end

  def load_trips(socket, user_id) do
    trips =
      user_id
      |> T.list_trips_with_assocs()
      |> Enum.group_by(fn trip ->
        case trip do
          %{start_date: date} when not is_nil(date) -> date.year
          %{inserted_at: date} -> date.year
        end
      end)

    assign(socket, :trips, trips)
  end

  def render(assigns) do
    ~H"""
      <div>
        <.heading_with_buttons>
          <:text_block>
            Trips
          </:text_block>

          <:button>
            <.button phx-click={JS.navigate("/trips/new")}>
              <Heroicons.plus_circle class="mr-1.5 h-5 w-5 flex-shrink-0 text-gray-400" />
              New Trip
            </.button>
          </:button>
        </.heading_with_buttons>

        <%= if @trips == %{} do %>
          <p class="text-lg dark:text-gray-400">No trips found</p>
        <% else %>
          <%= for {year, trips} <- @trips do %>
            <h2 class="text-xl pb-1 font-bold text-gray-900 dark:text-white">
              <%= year %> (<%= length(trips) %>)
            </h2>
            <%= for trip <- trips do %>
              <div phx-click={JS.navigate("/trips/#{trip.id}")} class="mb-3 w-full max-w-screen-xl cursor-pointer rounded-md bg-white bg-opacity-75 p-6 text-slate-800 dark:bg-slate-700 dark:bg-opacity-25 dark:text-slate-300 lg:p-4">
                <div class="flex flex-col justify-between w-full lg:flex-row">
                  <div class="ml-4 lg:w-2/6 self-center overflow-x-hidden">
                    <div class="w-full text-xl font-extrabold leading-5 pb-1">
                      <%= trip.name %>
                    </div>
                  </div>

                  <div class="w-full self-center pt-4 lg:w-1/6 lg:pt-0">
                    <div class="ml-1">
                      <div class="text-xl font-extrabold leading-5 tracking-tight"><%= trip.start_date %></div>
                    </div>
                  </div>

                  <div class="w-full self-center pt-4 lg:w-1/6 lg:pt-0">
                    <div class="ml-1">
                      <div class="text-xl font-extrabold leading-5 tracking-tight"><%= trip.end_date %></div>
                    </div>
                  </div>
                </div>

                <%= if length(trip.flights) > 0 do %>
                  <div class="mt-4 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
                    <%= for flight <- Enum.sort_by(trip.flights, &(&1.depart_date)) do %>
                      <.flight_card flight={flight} />
                    <% end %>
                  </div>
                <% end %>
              </div>
            <% end %>
          <% end %>
        <% end %>
      </div>
    """
  end
end
