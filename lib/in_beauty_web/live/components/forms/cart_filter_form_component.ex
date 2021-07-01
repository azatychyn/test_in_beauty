defmodule InBeautyWeb.Forms.CartFilterFormComponent do
  use InBeautyWeb, :live_component

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, :all_selected_filteres, [])}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~L"""
      <form phx-change="filter" phx-target="<%= @myself %>">
        <input type="hidden" name="page_size" value="<%= @filter_options.page_size %>">
        <input type="hidden" name="page" value="<%= @filter_options.page %>">
        <h1 class="w-max text-rose-100 dark:text-rose-300 text-4xl font-bold mx-auto py-6">
          <%= gettext("Filters") %>
        </h1>
        <section class="rounded-2xl dark:bg-midnight-500 mt-4 mx-auto w-11/12">
          <div class="flex flex-col w-full">
              <%= live_component(@socket, InBeautyWeb.MultiSelectComponent,
                    variants: @roles_variants, #TODO do list with enums for ecto
                    selected_variants: @filter_options.roles,
                    field: "roles",
                    placeholder: gettext("Role"),
                    device: @device
                  )
              %>
          </div>
        </section>
        <section class="flex flex-wrap w-11/12 mx-auto mt-6">
          <%= for {filter_group, selected_filter} <- all_selected_filters(@filter_options) do %>
            <p class="flex px-2 py-1 m-1 bg-gradient-to-r from-rose-100 to-rose-200 dark:border-rose-300 rounded-2xl text-xl text-center whitespace-nowrap ">
              <%= selected_filter %>
              <a
                class="flex items-center justify-center font-bold pl-4 text-4xl h-6 leading-3"
                phx-target="<%= @myself %>"
                phx-click="remove_filter"
                phx-value-filter_group="<%= filter_group %>"
                phx-value-filter="<%= selected_filter %>"
              >
                &times;
              </a>
            </p>
          <% end %>
        </section>
        <div class="flex mt-12 w-11/12 mx-auto">
          <p class="flex items-center text-xl xs:text-2xl sm:text-3xl md:text-5xl text-rose-200">
            <%= gettext("Find items:") %>
            <strong class="flex items-center justify-center h-8 sm:h-12 w-12 sm:w-28 bg-denim-100 text-white p-2 rounded-2xl mx-2 sm:mx-4"> <%= "#{@carts_count}" %></strong>
          </p>
          <%= reset(gettext("Reset All Filters"),
                "phx-click": "reset_filters",
                "phx-throttle": "1000",
                "phx-target":  @myself,
                class: "max-w-xs underline text-sm xs:text-lg sm:text-xl text-gray-100 hover:text-gray-500 dark:text-rose-100 font-medium py-2 px-0 sm:px-2 md:px-4 ml-auto bg-transparent rounded-2xl cursor-pointer text-center"
              )
          %>
        </div>
        <div class="flex justify-center mt-16 md:w-11/12 mx-auto">
          <%= if @carts_count do %>
            <%= live_redirect("Show",
              to:
                apply(
                  Routes,
                  @return_path,
                  [
                    @socket,
                    :index,
                    @filter_options
                  ]
                ),
                class: "sm:w-full uppercase max-w-xs p-4 xs:px-12 sm:px-6 md:px-8 xs:py-6 md:py-8 text-3xl dark:text-rose-100 font-bold bg-rose-100 hover:bg-rose-200 rounded-2xl dark:bg-denim-400 cursor-pointer text-center"
            ) %>
          <% end %>
        </div>
      </form>
    """
  end

  def handle_event("filter", params, socket) do
    filter_options = %{
      page: params["page"],
      page_size: params["page_size"],
      roles: params["roles"]
    }
    # socket = update(socket, :carts, fn _ -> [] end)
    {:noreply, cart_path_with_options(socket, :filters, filter_options)}
  end

  def handle_event("reset_filters", _, socket) do
    filter_options = %{
      roles: []
    }

    {:noreply, cart_path_with_options(socket, :filters, filter_options)}
  end

  def handle_event("remove_filter", %{"filter_group" => filter_group, "filter" => filter}, socket) do
    filter_group = String.to_atom(filter_group)
    filter_options =
      socket.assigns.filter_options
      |> update_in([filter_group], &(List.delete(&1, filter)))
    {:noreply, cart_path_with_options(socket, :filters, filter_options)}
  end

  def handle_event("price_change", [price_min, price_max], socket) do
    filter_options = Map.put(socket.assigns.filter_options, :price, [price_min, price_max])
    {:noreply, cart_path_with_options(socket, :filters, filter_options)}
  end

  defp all_selected_filters(filter_options) do
    filter_options
    |> Map.take([:roles])
    |> Enum.reduce([], fn {filter_group, filters}, acc ->
      filters_tuple =
        filters
        |> Enum.filter(&(&1 != ""))
        |> Enum.map(fn filter -> {filter_group, filter} end)
      filters_tuple ++ acc
    end)
  end
end
