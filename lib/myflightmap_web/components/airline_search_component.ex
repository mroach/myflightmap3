defmodule MyflightmapWeb.AirlineSearchComponent do
  use MyflightmapWeb, :live_component
  require Logger

  alias Myflightmap.Transport, as: TP

  @impl true
  def mount(socket) do
    {:ok, assign(socket, results: [], query: "", current_focus: 0, airline: nil)}
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
          airline = reload_or_reuse_airline(socket, id)
          query = airline.iata_code
          [airline: airline, query: query]
      end

    socket = assign(socket, existing_value_assigns)

    {:ok, socket}
  end

  defp reload_or_reuse_airline(socket, nil), do: socket
  defp reload_or_reuse_airline(socket, want_airline_id) do
    case socket.assigns.airline do
      %{id: ^want_airline_id} = airline -> airline
      _ -> TP.get_airline!(want_airline_id)
    end
  end

  def handle_event("search", %{"value" => ""}, socket) do
    {:noreply, assign(socket, results: [], query: "")}
  end

  def handle_event("search", %{"value" => query, "key" => key}, socket) do
    if query == socket.assigns.query do
      {:noreply, socket}
    else
      results = TP.search_airlines(query)

      {:noreply,
       socket
       |> assign(:results, results)
       |> assign(:query, query)
       |> assign(:current_focus, 0)}
    end
  end

  def handle_event("pick", %{"airline-id" => id}, socket) do
    airline = TP.get_airline!(id)

    send(
      self(),
      {
        :picked_airline,
        %{airline: airline}
      }
    )

    {:noreply, assign(socket, results: [])}
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
      %{airline: airline} -> handle_event("pick", %{"airline-id" => airline.id}, socket)
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
          placeholder="Airline search",
          class="block w-80 rounded-md border-gray-300 focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm" />

        <%= if @airline do %>
          <div><%= @airline.name %></div>
        <% end %>

        <%= if @results != [] do %>
          <div class="relative" phx-window-keydown="set-focus" phx-target={@myself}>
            <div class="absolute z-50 left-0 right-0 border border-gray-100 shadow py-2 bg-white w-80 max-h-64 overflow-scroll divide-y">
              <%= for {%{airline: airline}, idx} <- Enum.with_index(@results) do %>
                <div phx-click="pick" phx-target={@myself} phx-value-airline-id={airline.id} data-scroll-index={idx}
                  class={"cursor-pointer p-2 hover:bg-gray-200 focus:bg-gray-200 flex flex-row items-center #{if idx == @current_focus, do: "bg-gray-200"}"}>
                  <div class="basis-1/5">
                    <span class="inline-block rounded text-slate-300 bg-gray-900 px-1 size-sm font-bold"><%= airline.iata_code %></span>
                  </div>
                  <div>
                    <div><%= Unicode.emoji_flag(airline.country) %> <%= airline.name %></div>
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
