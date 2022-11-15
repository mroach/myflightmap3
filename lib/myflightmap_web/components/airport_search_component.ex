defmodule MyflightmapWeb.AirportSearchComponent do
  use MyflightmapWeb, :live_component
  require Logger

  alias Myflightmap.Transport, as: TP

  @impl true
  def mount(socket) do
    {:ok, assign(socket, results: [], query: "", current_focus: 0, airport: nil)}
  end

  def update(assigns, socket) do
    %{id: id, f: f} = assigns
    id = String.to_existing_atom(id)

    socket = assign(socket, id: id, f: f)

    existing_value_assigns =
      case Phoenix.HTML.Form.input_value(f, id) do
        nil -> []
        "" -> []
        id ->
          airport = reload_or_reuse_airport(socket, id)
          query = airport.iata_code
          [airport: airport, query: query]
      end

    socket = assign(socket, existing_value_assigns)

    {:ok, socket}
  end

  defp reload_or_reuse_airport(socket, nil), do: nil
  defp reload_or_reuse_airport(socket, want_airport_id) do
    case socket.assigns.airport do
      %{id: ^want_airport_id} = airport -> airport
      _ -> TP.get_airport!(want_airport_id)
    end
  end

  @impl true
  def handle_event("search", %{"key" => key}, socket)
      when key in ["ArrowUp", "ArrowDown", "Enter"] do
    {:noreply, socket}
  end

  def handle_event("search", %{"value" => ""}, socket) do
    {:noreply, assign(socket, results: [], query: "")}
  end

  def handle_event("search", %{"value" => query, "key" => key}, socket) do
    if query == socket.assigns.query do
      {:noreply, socket}
    else
      results = TP.search_airports(query)

      {:noreply,
       socket
       |> assign(:results, results)
       |> assign(:query, query)
       |> assign(:current_focus, 0)}
    end
  end

  def handle_event("pick", %{"airport-id" => id}, socket) do
    airport = TP.get_airport!(id)

    send(
      self(),
      {
        :picked_airport,
        %{control_id: socket.assigns.id, airport: airport}
      }
    )

    {:noreply,
     socket
     |> assign(:results, [])
     |> assign(:query, airport.iata_code)}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, results: [])}
  end

  def handle_event("set-focus", %{"key" => "ArrowUp"}, socket) do
    current_focus = Enum.max([socket.assigns.current_focus - 1, 0])

    {:noreply,
     socket
     |> assign(:current_focus, current_focus)
     |> push_event("scroll-to-element", %{selector: ~s|[data-scroll-index="#{current_focus}"]|})}
  end

  def handle_event("set-focus", %{"key" => "ArrowDown"}, socket) do
    current_focus =
      Enum.min([socket.assigns.current_focus + 1, length(socket.assigns.results) - 1])

    {:noreply,
     socket
     |> assign(:current_focus, current_focus)
     |> push_event("scroll-to-element", %{selector: ~s|[data-scroll-index="#{current_focus}"]|})}
  end

  def handle_event("set-focus", %{"key" => "Enter"} = params, socket) do
    case Enum.at(socket.assigns.results, socket.assigns.current_focus) do
      %{airport: airport} -> handle_event("pick", %{"airport-id" => airport.id}, socket)
      _ -> {:noreply, socket}
    end
  end

  def handle_event("set-focus", %{"key" => "Escape"}, socket) do
    handle_event("cancel", %{}, socket)
  end

  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
      <div phx-click-away="cancel" phx-target={@myself}>
        <%= hidden_input assigns.f, assigns.id %>
        <input
          type="text"
          value={@query}
          phx-debounce="200"
          phx-keyup="search"
          phx-target={@myself}
          placeholder="Airport search",
          class="block w-80 rounded-md border-gray-300 focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm" />

        <%= if @airport do %>
          <div class="py-2">
            <span class="inline-block rounded text-slate-300 bg-gray-900 px-1 size-sm font-bold"><%= @airport.iata_code %></span>
            <%= @airport.common_name %>
          </div>
        <% end %>

        <%= if @results != [] do %>
          <div class="relative" phx-window-keydown="set-focus" phx-target={@myself}>
            <div class="absolute z-50 left-0 right-0 border border-gray-100 shadow py-2 bg-white w-80 max-h-64 overflow-scroll divide-y">
              <%= for {%{airport: airport}, idx} <- Enum.with_index(@results) do %>
                <div phx-click="pick" phx-target={@myself} phx-value-airport-id={airport.id} data-scroll-index={idx}
                  class={"cursor-pointer p-2 hover:bg-gray-200 focus:bg-gray-200 flex flex-row items-center #{if idx == @current_focus, do: "bg-gray-200"}"}>
                  <div class="basis-1/4">
                    <span class="inline-block rounded text-slate-300 bg-gray-900 px-1 size-sm font-bold"><%= airport.iata_code %></span>
                  </div>
                  <div>
                    <div><%= airport.common_name %></div>
                    <%= Unicode.emoji_flag(airport.country) %> <%= airport.city %>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        <% end %>
      </div>
    """
  end
end
