defmodule MyflightmapWeb.FlightLive.Edit do
  use MyflightmapWeb, :live_view
  require Logger

  alias Myflightmap.Travel, as: T

  @impl true
  def mount(params, session, socket) do
    {:ok, user} = MyflightmapWeb.Auth.user_from_session(session)

    flight_id = case params do
      %{"id" => id} -> id
      _ -> nil
    end

    trip_id = case params do
      %{"trip_id" => id} -> id
      _ -> nil
    end

    flight = case flight_id do
      nil -> %T.Flight{trip_id: trip_id}
      id -> T.get_flight!(id)
    end

    flight_code_prefix = case flight.airline_id do
      nil -> nil
      id -> Myflightmap.Transport.get_airline!(id).iata_code
    end

    trip_options = T.list_trips(user.id) |> Enum.map(fn trip -> {trip.name, trip.id} end)

    changeset = T.change_flight(flight)

    {:ok,
     socket
     |> assign(:flight_id, flight_id)
     |> assign(:changeset, changeset)
     |> assign(:flight_code_prefix, flight_code_prefix)
     |> assign(:trip_options, trip_options)
     |> assign(:user, user)
   }
  end

  @impl true
  def handle_info({:picked_airport, data}, socket) do
    %{control_id: control_id, airport: airport} = data

    changeset = socket.assigns.changeset |> Ecto.Changeset.put_change(control_id, airport.id)

    {:noreply,
     socket
     |> assign(:changeset, changeset)}
  end

  def handle_info({:picked_airline, %{airline: airline}}, socket) do
    changeset = socket.assigns.changeset |> Ecto.Changeset.put_change(:airline_id, airline.id)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:flight_code_prefix, airline.iata_code)}
  end

  def handle_event("validate", %{"flight" => params}, socket) do
    changeset = T.change_flight(socket.assigns.changeset.data, params)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"flight" => params}, socket) do

    result = case socket.assigns.flight_id do
      nil ->
        T.create_flight(socket.assigns.user, params)
      id ->
        id
        |> T.get_flight!()
        |> T.update_flight(params)
    end

    case result do
      {:error, changeset} ->
        IO.puts("Saving FAILED:")
        IO.inspect(changeset)
        {:noreply, assign(socket, changeset: changeset)}
      {:ok, flight} ->
        {:noreply, push_navigate(socket, to: "/flights/#{flight.id}")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="md:grid md:grid-cols-3 md:gap-6">

        <div class="md:col-span-1">
          <div class="px-4 sm:px-0">
            <h3 class="text-lg font-medium leading-6 text-gray-900 dark:text-white">Flight Information</h3>
            <p class="mt-1 text-sm text-gray-600 dark:text-white">Enter as much information as you can about your flight.</p>
          </div>
        </div>

        <div class="mt-5 md:col-span-2 md:mt-0">
          <.form :let={f} for={@changeset} phx-change="validate" phx-submit="save" phx-debounce="300">
            <div class="overflow-hidden shadow sm:rounded-md">

              <div class="bg-white px-4 py-5 sm:p-6">
                <div class="grid grid-cols-6 gap-6">

                  <div class="col-span-6 sm:col-span-3">
                    <%= label f, :airline_id, class: "block mb-1 text-sm font-medium text-gray-700" %>
                    <.live_component module={MyflightmapWeb.AirlineSearchComponent} id="airline_id" f={f} />
                    <%= error_tag f, :airline_id %>
                  </div>

                  <div class="col-span-6 sm:col-span-3">
                    <%= label f, :flight_code, class: "block mb-1 text-sm font-medium text-gray-700" %>
                    <div class="flex rounded-md">
                      <span class="inline-flex items-center rounded-l-md border border-r-0 border-gray-300 bg-gray-50 px-3 text-sm text-gray-500"><%= @flight_code_prefix %></span>
                      <%= text_input f, :flight_code, class: "rounded-none rounded-r-md border-gray-300 focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm" %>
                    </div>
                    <%= error_tag f, :flight_code %>
                  </div>

                  <div class="col-span-6 sm:col-span-3">
                    <%= label f, :depart_airport_id, class: "block mb-1 text-sm font-medium text-gray-700" %>
                    <.live_component module={MyflightmapWeb.AirportSearchComponent} id="depart_airport_id" f={f} />
                    <%= error_tag f, :depart_airport_id %>
                  </div>

                  <div class="col-span-6 sm:col-span-3">
                    <%= label f, :arrive_airport_id, class: "block mb-1 text-sm font-medium text-gray-700" %>
                    <.live_component module={MyflightmapWeb.AirportSearchComponent} id="arrive_airport_id" f={f} />
                    <%= error_tag f, :arrive_airport_id %>
                  </div>

                  <div class="col-span-6 sm:col-span-3">
                    <%= label f, :depart_date, class: "block mb-1 text-sm font-medium text-gray-700" %>
                    <%= date_input f, :depart_date, class: "mt-1 block rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm" %>
                    <%= error_tag f, :depart_date %>
                  </div>

                  <div class="col-span-6 sm:col-span-3">
                    <%= label f, :depart_time, class: "block mb-1 text-sm font-medium text-gray-700" %>
                    <%= time_input f, :depart_time, class: "mt-1 block rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm" %>
                    <%= error_tag f, :depart_time %>
                  </div>

                  <div class="col-span-6 sm:col-span-3">
                    <%= label f, :arrive_date, class: "block mb-1 text-sm font-medium text-gray-700" %>
                    <%= date_input f, :arrive_date, class: "mt-1 block rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm" %>
                    <%= error_tag f, :arrive_date %>
                  </div>

                  <div class="col-span-6 sm:col-span-3">
                    <%= label f, :arrive_time, class: "block mb-1 text-sm font-medium text-gray-700" %>
                    <%= time_input f, :arrive_time, class: "mt-1 block rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm" %>
                    <%= error_tag f, :arrive_time %>
                  </div>

                  <div class="col-span-6 sm:col-span-3">
                    <%= label f, :seat_class, class: "block mb-1 text-sm font-medium text-gray-700" %>
                    <%= select f, :seat_class, Myflightmap.Transport.list_seat_class_options(), class: "mt-1 block rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm" %>
                    <%= error_tag f, :seat_class %>
                  </div>

                  <div class="col-span-6 sm:col-span-3">
                    <%= label f, :seat, class: "block mb-1 text-sm font-medium text-gray-700" %>
                    <%= text_input f, :seat, class: "mt-1 block rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm" %>
                    <%= error_tag f, :seat %>
                  </div>

                  <div class="col-span-6 sm:col-span-3">
                    <%= label f, :trip_id, class: "block mb-1 text-sm font-medium text-gray-700" %>
                    <%= select f, :trip_id, @trip_options, prompt: "-- Trip -- ", class: "mt-1 block rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm" %>
                    <%= error_tag f, :trip_id %>
                  </div>
                </div>
              </div>

              <div class="bg-gray-50 px-4 py-3 text-right sm:px-6">
                <%= submit "Submit", class: "inline-flex justify-center rounded-md border border-transparent bg-indigo-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2" %>
              </div>
            </div>
          </.form>
        </div>
      </div>
    """
  end
end
