defmodule MyflightmapWeb.HeadingComponent do
  use MyflightmapWeb, :live_component

  slot :button, required: true
  slot :sub_item, required: false
  slot :text_block, required: false
  attr :text, :string, required: false
  def heading_with_buttons(assigns) do
    ~H"""
      <div class="lg:flex lg:items-center lg:justify-between mb-5">
        <div class="min-w-0 flex-1">
          <h2 class="text-2xl pb-1 font-bold leading-7 text-gray-900 dark:text-white sm:truncate sm:text-3xl sm:tracking-tight">
            <%= assigns[:text] || render_slot(@text_block) %>
          </h2>
          <div class="mt-1 flex flex-col sm:mt-0 sm:flex-row sm:flex-wrap sm:space-x-6">
            <%= for item <- @sub_item do %>
              <div class="mt-2 flex items-center text-sm text-gray-500">
                <%= render_slot(item) %>
              </div>
            <% end %>
          </div>
        </div>

        <div class="mt-5 flex lg:mt-0 lg:ml-4">
          <%= for button <- @button do %>
            <span class="ml-3">
              <%= render_slot(button) %>
            </span>
          <% end %>
        </div>
      </div>

    """
  end
end
