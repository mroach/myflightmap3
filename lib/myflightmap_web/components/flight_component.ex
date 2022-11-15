defmodule MyflightmapWeb.FlightComponent do
  use MyflightmapWeb, :live_component

  import MyflightmapWeb.Helpers.{AirlineHelpers, DateTimeHelpers, FlightHelpers}

  attr :flight, Myflightmap.Travel.Flight, required: true

  def flight_card(assigns) do
    ~H"""
      <div
        phx-click={JS.navigate("/flights/#{@flight.id}")}
        class={"flex items-start rounded-xl bg-white p-4 shadow-lg border-t-2 dark:bg-slate-700 dark:bg-opacity-25 dark:text-slate-300 #{seat_class_border(@flight.seat_class)}"}>
        <div class="flex h-12 w-12 items-center justify-center rounded-full border border-gray-100 bg-gray-50">
          <%= airline_logo(@flight.airline) %>
        </div>

        <div class="ml-4 w-48">
          <div class="flex w-full flex-row justify-between font-semibold">
            <div><%= @flight.depart_airport.iata_code %> ✈ <%= @flight.arrive_airport.iata_code %></div>
            <div><%= @flight.airline.iata_code %> <%= @flight.flight_code %></div>
          </div>
          <p class="mt-2 text-sm text-gray-500"><%= date_time_format(@flight.depart_date) %></p>
        </div>
      </div>
    """
  end

  def flight_inline(assigns) do
    ~H"""
      <div phx-click={JS.navigate("/flights/#{@flight.id}")} class={"mb-3 flex w-full max-w-screen-xl transform cursor-pointer flex-col justify-between rounded-md bg-white bg-opacity-75 p-6 text-slate-800 transition duration-300 ease-in-out hover:shadow-lg dark:bg-slate-700 dark:bg-opacity-25 dark:text-slate-300 lg:flex-row lg:p-4 border-t-2 #{seat_class_border(@flight.seat_class)}"}>
        <div class="flex w-full flex-row lg:w-1/12">
          <div class="relative flex flex-col">
            <div class="flex h-12 w-12 p-2 flex-shrink-0 flex-col justify-center rounded-full bg-white">
              <%= airline_logo(@flight.airline, "[35px]") %>
            </div>
          </div>
        </div>

        <div class="ml-4 lg:w-1/6 self-center overflow-x-hidden">
          <div class="w-full truncate text-xl font-extrabold leading-5 tracking-tight">
            <%= @flight.airline.iata_code %> <%= @flight.flight_code %>
          </div>
          <div class="text-sm text-slate-500"><%= @flight.airline.name %></div>
        </div>

        <div class="w-full self-center pt-4 lg:w-1/6 lg:pt-0">
          <div class="ml-1">
            <div class="text-xl font-extrabold leading-5 tracking-tight">
              <%= @flight.depart_date %>
            </div>
            <div class="text-sm text-slate-500 flex justify-between">
              <div>
                <%= date_time_format(@flight.depart_time, "%H:%M") %> - <%= date_time_format(@flight.arrive_time, "%H:%M") %>
                <%= formatted_timechange(@flight) %>
              </div>
              <div>
                <%= if (duration = formatted_duration(@flight)) do %>
                  <Heroicons.clock class="inline-block h-4 w-4 text-gray-400" />
                  <%= duration %>
                <% end %>
              </div>
            </div>
          </div>
        </div>

        <div class="w-full self-center pt-4 lg:w-1/6 lg:pt-0">
          <div class="ml-1">
            <div class="text-xl font-extrabold leading-5 tracking-tight"><%= @flight.depart_airport.iata_code %></div>
            <div class="text-sm text-slate-500">
              <%= @flight.depart_airport.common_name %>
            </div>
          </div>
        </div>

        <div class="w-full self-center pt-4 lg:w-1/6 lg:pt-0">
          <div class="ml-1">
            <div class="text-xl font-extrabold leading-5 tracking-tight"><%= @flight.arrive_airport.iata_code %></div>
            <div class="text-sm text-slate-500">
              <%= @flight.arrive_airport.common_name %>
            </div>
          </div>
        </div>

        <div class="w-full self-center pt-4 lg:w-1/6 lg:pt-0">
          <div class="ml-1">
            <div class="text-xl font-extrabold leading-5 tracking-tight">
              <span class={"text-[12px] rounded px-1.5 py-0.5 align-middle font-bold uppercase text-white #{seat_class_style(@flight.seat_class)}"}>
                <%= seat_class_label(@flight.seat_class) %>
              </span>
            </div>
            <div class="text-sm text-slate-500">
              <%= @flight.seat %>
            </div>
          </div>
        </div>
      </div>
    """
  end

  defp seat_class_label(txt) do
    txt
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  # Tailwind only works when complete class name strings are present in the source code,
  # hence the clear DRY violation here.
  # https://tailwindcss.com/docs/content-configuration#dynamic-class-names
  defp seat_class_style(name) do
    case name do
      "economy" -> "bg-green-800"
      "premium_economy" -> "bg-blue-800"
      "business" -> "bg-yellow-600"
      "first" -> "bg-violet-700"
      "suites" -> "bg-red-800"
      _ -> "inherit"
    end
  end

  defp seat_class_border(name) do
    case name do
      "economy" -> "border-t-green-800"
      "premium_economy" -> "border-t-blue-800"
      "business" -> "border-t-yellow-600"
      "first" -> "border-t-violet-700"
      "suites" -> "border-t-red-800"
      _ -> "inherit"
    end
  end
end
