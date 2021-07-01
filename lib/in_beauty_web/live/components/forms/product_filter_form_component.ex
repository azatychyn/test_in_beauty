defmodule InBeautyWeb.Forms.ProductFilterFormComponent do
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
        <div phx-target="<%= @myself %>" phx-update="ignore" class="my-12 w-9/12 md:w-11/12 mx-auto">
          <div
            id="price_slider"
            phx-hook="PriceSlider"
            phx-target="<%= @myself %>"
            data-min_price="<%= List.first(@filter_options.price) %>"
            data-max_price="<%= List.last(@filter_options.price) %>"
          >
          </div>
        </div>
        <div class="flex justify-between w-11/12 mx-auto py-6">
          <input
            type="text"
            id="min_price"
            name="price[]"
            value="<%= List.first(@filter_options.price) %>"
            phx-debounce="blur"
            phx-hook="NumberInput"
            phx-update="ignore"
            phx-target="<%= @myself %>"
            inputmode="numeric"
            pattern="[0-9]*"
            class="w-16 md:w-24 p-1 md:p-4 text-lg text-center font-medium dark:text-midnight-500 rounded-2xl focus:outline-none focus:ring focus:ring-bright-pink-dribble dark:focus:ring-rose-100 focus:bg-white bg-rose-100 dark:focus:bg-white"
          >
          <input
            type="text"
            id="max_price"
            name="price[]"
            value="<%= List.last(@filter_options.price) %>"
            phx-debounce="blur"
            phx-hook="NumberInput"
            phx-update="ignore"
            phx-target="<%= @myself %>"
            inputmode="numeric"
            pattern="[0-9]*"
            class="w-16 md:w-24 p-1 md:p-4 text-lg text-center font-medium dark:text-midnight-500 rounded-2xl focus:outline-none focus:ring focus:ring-bright-pink-dribble dark:focus:ring-rose-100 focus:bg-white bg-rose-100 dark:focus:bg-white"
          >
        </div>
        <section class="rounded-2xl dark:bg-midnight-500 mt-4 mx-auto w-11/12">
          <div class="flex flex-col w-full">
              <%= live_component(@socket, InBeautyWeb.MultiSelectComponent,
                    variants: @volumes_variants, #TODO do list with enums for ecto
                    selected_variants: @filter_options.volumes,
                    field: "volumes",
                    placeholder: gettext("Volume"),
                    device: @device
                  )
              %>
              <%= live_component(@socket, InBeautyWeb.MultiSelectComponent,
                    variants: @genders_variants, #TODO do list with enums for ecto
                    selected_variants: @filter_options.genders,
                    field: "genders",
                    placeholder: gettext("Gender"),
                    device: @device
                  )
              %>
              <%= live_component(@socket, InBeautyWeb.MultiSelectComponent,
                    variants: [], #TODO do list with enums for ecto
                    selected_variants: @filter_options.manufacturers,
                    field: "manufacturers",
                    placeholder: gettext("Manufacturer"),
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
            <strong class="flex items-center justify-center h-8 sm:h-12 w-12 sm:w-28 bg-denim-100 text-white p-2 rounded-2xl mx-2 sm:mx-4"> <%= "#{@products_count}" %></strong>
          </p>
          <%= reset(gettext("Reset All Filters"),
                "phx-click": "reset_filters",
                "phx-throttle": "1000",
                "phx-target":  @myself,
                class: "max-w-xs underline text-md xs:text-xl sm:text-2xl text-gray-100 hover:text-gray-500 dark:text-rose-100 font-medium py-2 px-0 sm:px-2 md:px-4 ml-auto bg-transparent rounded-2xl cursor-pointer text-center"
              )
          %>
        </div>
        <div class="flex justify-center mt-16 md:w-11/12 mx-auto">
          <%= if @products_count do %>
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
      price: params["price"],
      volumes: params["volumes"],
      manufacturers: params["manufacturers"],
      genders: params["genders"]
    }
    # socket = update(socket, :products, fn _ -> [] end)
    {:noreply, product_path_with_options(socket, :filters, filter_options)}
  end

  def handle_event("reset_filters", _, socket) do
    filter_options = %{
      genders: [],
      volumes: [],
      manufacturers: [],
      price: ["0", "10000"]
    }

    {:noreply, product_path_with_options(socket, :filters, filter_options)}
  end

  def handle_event("remove_filter", %{"filter_group" => filter_group, "filter" => filter}, socket) do
    filter_group = String.to_atom(filter_group)
    filter_options =
      socket.assigns.filter_options
      |> update_in([filter_group], &(List.delete(&1, filter)))
    {:noreply, product_path_with_options(socket, :filters, filter_options)}
  end

  def handle_event("price_change", [price_min, price_max], socket) do
    filter_options = Map.put(socket.assigns.filter_options, :price, [price_min, price_max])
    {:noreply, product_path_with_options(socket, :filters, filter_options)}
  end

  defp all_selected_filters(filter_options) do
    filter_options
    |> Map.take([:volumes, :manufactureers, :genders])
    |> Enum.reduce([], fn {filter_group, filters}, acc ->
      filters_tuple =
        filters
        |> Enum.filter(&(&1 != ""))
        |> Enum.map(fn filter -> {filter_group, filter} end)
      filters_tuple ++ acc
    end)
  end
end
