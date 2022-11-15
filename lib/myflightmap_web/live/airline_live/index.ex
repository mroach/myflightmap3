defmodule MyflightmapWeb.AirlineLive.Index do
  use MyflightmapWeb, :live_view
  require Logger

  alias Myflightmap.Transport, as: T
  import MyflightmapWeb.Helpers.AirlineHelpers

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> load_paginated_airlines(nil)
      |> assign(:page_title, "Airlines")
      |> assign(:query, nil)

    {:ok, socket}
  end

  def load_paginated_airlines(socket, query, pagination \\ []) do
    current_page = Keyword.get(pagination, :page, 0)
    pagination_opts = [page_size: 50, page: current_page]

     {pagination, airlines} = case query do
      blank when blank in [nil, ""] ->
        {:ok, %{pagination: pagination, records: airlines}} =
          T.list_airlines(pagination: pagination_opts)
        {pagination, airlines}
      term ->
        {:ok, %{pagination: pagination, records: records}} =
          T.search_airlines_paginated(term, pagination: pagination_opts)

        airlines = Enum.map(records, &(&1.airline))
        {pagination, airlines}
      end

    socket
     |> assign(:airlines, airlines)
     |> assign(:pagination, pagination)
     |> assign(:query, query)
  end

  @impl true
  def handle_event("page-prev", _, socket) do
    pagination_opts = [page: socket.assigns.pagination.page - 1]
    query = socket.assigns.query
    socket = load_paginated_airlines(socket, query, pagination_opts)
    {:noreply, socket}
  end

  def handle_event("page-next", _, socket) do
    pagination_opts = [page: socket.assigns.pagination.page + 1]
    query = socket.assigns.query
    socket = load_paginated_airlines(socket, query, pagination_opts)
    {:noreply, socket}
  end

  def handle_event("search", %{"value" => query}, socket) do
    socket = load_paginated_airlines(socket, query)
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="overflow-x-auto relative shadow-md sm:rounded-lg">
        <div class="flex justify-between items-center pb-4 bg-white dark:bg-gray-900">
          <div class="bg-white dark:bg-gray-900">
            <label for="table-search" class="sr-only">Search</label>
            <div class="relative mt-1">
              <div class="flex absolute inset-y-0 left-0 items-center pl-3 pointer-events-none">
                  <svg class="w-5 h-5 text-gray-500 dark:text-gray-400" aria-hidden="true" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd"></path></svg>
              </div>
              <input
                type="search"
                phx-keyup="search"
                phx-debounce="200"
                value={@query}
                class="block p-2 pl-10 w-80 text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-300 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                placeholder="Search">
            </div>
          </div>

          <nav class="flex justify-between items-center pt-2">
            <span class="text-sm text-gray-700 dark:text-gray-400 px-4 pt-2">
              Showing
              <span class="font-semibold text-gray-900 dark:text-white"><%= @pagination.first_record_index %></span>
              to
              <span class="font-semibold text-gray-900 dark:text-white"><%= @pagination.last_record_index %></span>
              of
              <span class="font-semibold text-gray-900 dark:text-white">
                <%= @pagination.total_record_count %>
              </span>
              records
            </span>

            <div class="inline-flex items-center mt-2 xs:mt-0">
              <button
                phx-click="page-prev"
                disabled={not @pagination.has_prev?}
                class="inline-flex items-center py-2 px-4 text-sm font-medium text-white bg-gray-800 rounded-l hover:bg-gray-900 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white">
                  <svg aria-hidden="true" class="mr-2 w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M7.707 14.707a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l2.293 2.293a1 1 0 010 1.414z" clip-rule="evenodd"></path></svg>
                  Prev
              </button>
              <button
                phx-click="page-next"
                disabled={not @pagination.has_next?}
                class="inline-flex items-center py-2 px-4 text-sm font-medium text-white bg-gray-800 rounded-r border-0 border-l border-gray-700 hover:bg-gray-900 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white">
                  Next
                  <svg aria-hidden="true" class="ml-2 w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M12.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-2.293-2.293a1 1 0 010-1.414z" clip-rule="evenodd"></path></svg>
              </button>
            </div>
          </nav>
        </div>

        <%= if length(@airlines) == 0 do %>
          <p class="text-lg dark:text-gray-400">No results for "<%= @query %>"</p>
        <% else %>
          <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
            <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
              <tr>
                <th class="py-3 px-6">IATA Code</th>
                <th class="py-3 px-6">ICAO Code</th>
                <th class="py-3 px-6">Name</th>
                <th class="py-3 px-6">Home Country</th>
                <th class="py-3 px-6">Established</th>
                <th class="py-3 px-6">Defunct</th>
              </tr>
            </thead>

            <tbody>
              <%= for airline <- @airlines do %>
                <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700">
                  <td class="py-4 px-6">
                    <div class="inline-flex items-center justify-between w-12">
                      <%= airline.iata_code %>
                      <%= airline_logo(airline) %>
                    </div>
                  </td>
                  <td class="py-4 px-6"><%= airline.icao_code %></td>
                  <td class="py-4 px-6"><%= airline.name %></td>
                  <td class="py-4 px-6"><%= Unicode.emoji_flag(airline.country) %></td>
                  <td class="py-4 px-6"><%= airline.commenced_on %></td>
                  <td class="py-4 px-6"><%= airline.ceased_on %></td>
                </tr>
              <% end %>
            </tbody>
          </table>
        <% end %>
      </div>
    """
  end
end
