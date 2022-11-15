defmodule MyflightmapWeb.TripLive.Edit do
  use MyflightmapWeb, :live_view
  require Logger

  alias Myflightmap.Travel, as: T

  @impl true
  def mount(params, session, socket) do
    {:ok, user} = MyflightmapWeb.Auth.user_from_session(session)

    trip_id = case params do
      %{"id" => id} -> id
      _ -> nil
    end

    trip = case trip_id do
      nil -> %T.Trip{}
      id -> T.get_trip!(id)
    end

    changeset = T.change_trip(trip)

    {:ok,
     socket
     |> assign(:trip_id, trip_id)
     |> assign(:changeset, changeset)
     |> assign(:user, user)
   }
  end

  def handle_event("validate", %{"trip" => params}, socket) do
    changeset = T.change_trip(socket.assigns.changeset.data, params)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"trip" => params}, socket) do
    result = case socket.assigns.trip_id do
      nil ->
        IO.puts("Creating new trip")
        IO.inspect(params)
        T.create_trip(socket.assigns.user, params)
      id ->
        IO.puts("UPdating existing trip")
        id
        |> T.get_trip!()
        |> T.update_trip(params)
    end

    case result do
      {:error, changeset} ->
        IO.puts("Saving FAILED:")
        IO.inspect(changeset)
        {:noreply, assign(socket, changeset: changeset)}
      {:ok, trip} ->
        {:noreply, push_navigate(socket, to: "/trips/#{trip.id}")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="md:grid md:grid-cols-3 md:gap-6">

        <div class="md:col-span-1">
          <div class="px-4 sm:px-0">
            <h3 class="text-lg font-medium leading-6 text-gray-900 dark:text-white">Trip Information</h3>
            <p class="mt-1 text-sm text-gray-600 dark:text-white">
              Trips group flights together under one name.
            </p>
          </div>
        </div>

        <div class="mt-5 md:col-span-2 md:mt-0">
          <.form :let={f} for={@changeset} phx-change="validate" phx-submit="save" phx-debounce="300">
            <div class="overflow-hidden shadow sm:rounded-md">
              <div class="bg-white px-4 py-5 sm:p-6">
                <div class="grid grid-cols-6 gap-6">
                  <div class="col-span-6 sm:col-span-3">
                    <%= label f, :name, class: "block mb-1 text-sm font-medium text-gray-700" %>
                    <%= text_input f, :name, class: "mt-1 block rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm" %>
                    <%= error_tag f, :name %>
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
