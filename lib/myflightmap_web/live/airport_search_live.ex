defmodule MyflightmapWeb.AirportSearchLive do
  use Phoenix.LiveView

  alias Myflightmap.Transport
  require Logger

  def render(assigns) do
    ~L"""
    <input phx-keyup="suggest" type="text" name="airport" autocomplete="off" list="matches" placeholder="Find airport..."
      <%= if @loading, do: "readonly" %>/>
    <datalist id="matches">
      <%= for {value, text} <- @matches do %>
        <option value="<%= value %>" label="<%= text %>"><%= text %></option>
      <% end %>
    </datalist>
    <%= inspect(@matches) %>
    <%= if @result do %><pre><%= @result %></pre><% end %>
    <%= @tick %>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(1_000, self(), :tick)
    {:ok, assign(socket, query: nil, result: nil, loading: false, matches: [], tick: 1)}
  end

  def handle_event("suggest", query, socket) do
    exact_match =
      case Transport.get_airport_by_iata(query) do
        nil -> []
        airport ->
          text = MyflightmapWeb.Helpers.AirportHelpers.airport_name(airport)
          [{airport.id, "#{airport.iata_code}  - #{text}"}]
      end
    matches = [] ++ exact_match
    {:noreply, assign(socket, matches: matches)}
  end

  def handle_event(event, data, socket) do
    Logger.info "Unhandled event #{event}: #{inspect(data)}"

    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, tick: DateTime.utc_now |> DateTime.to_unix)}
  end
end
