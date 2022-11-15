defmodule MyflightmapWeb.FlightLive.Index do
  use MyflightmapWeb, :live_view
  require Logger

  alias Myflightmap.Travel, as: T
  import MyflightmapWeb.FlightComponent, only: [flight_inline: 1]
  import MyflightmapWeb.{HeadingComponent}

  @impl true
  def mount(_params, session, socket) do
    %{"guardian_default_token" => token} = session
    {:ok, claims} = Myflightmap.Auth.Guardian.decode_and_verify(token)
    %{"sub" => user_id} = claims

    socket =
      socket
      |> load_flights(user_id)

    {:ok, socket}
  end

  def load_flights(socket, user_id) do
    flights = T.list_flights_with_assocs(user_id)
    assign(socket, :flights, flights)
  end

  def render(assigns) do
    ~H"""
      <div>
        <.heading_with_buttons>
          <:text_block>
            Flights
          </:text_block>

          <:button>
            <.button phx-click={JS.navigate("/flights/new")}>
              <Heroicons.plus_circle class="mr-1.5 h-5 w-5 flex-shrink-0 text-gray-400" />
              Add Flight
            </.button>
          </:button>
        </.heading_with_buttons>

        <%= if length(@flights) == 0 do %>
          <p class="text-lg dark:text-gray-400">No flights found</p>
        <% else %>
          <%= for flight <- @flights do %>
            <.flight_inline flight={flight} />
          <% end %>
        <% end %>
      </div>
    """
  end
end
