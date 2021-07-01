defmodule InBeautyWeb.MapComponent do
  use InBeautyWeb, :live_component

  alias InBeauty.Sdek.Sdek

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    active_delivery_point = assigns.delivery_point || %InBeauty.Deliveries.DeliveryPoint{}
    delivery_point = assigns.delivery_point || %InBeauty.Deliveries.DeliveryPoint{}
    delivery = maybe_put_geo_coordinates(assigns.delivery, assigns.delivery_points)

    socket =
      socket
      |> assign(assigns)
      |> assign(:active_delivery_point, active_delivery_point)
      |> assign(:delivery_point, delivery_point)
      |> assign(:delivery, delivery)
    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~L"""
      <div class="flex h-full">
        <leaflet-map
          lat="<%= @active_delivery_point.latitude || @delivery.latitude %>"
          lng="<%= @active_delivery_point.longitude || @delivery.longitude %>"
          class="block w-full"
        >
          <%= for delivery_point <- @delivery_points do %>
            <leaflet-marker
              lat="<%= delivery_point.latitude %>"
              lng="<%= delivery_point.longitude %>"
              selected="<%= delivery_point.code == @active_delivery_point.code %>"
              phx-click="make_active_delivery_point"
              phx-target="<%= @myself %>"
              phx-value-code="<%= delivery_point.code %>">
              <leaflet-icon
                icon-url="<%= get_icon_url(delivery_point.code == @delivery_point.code) %>"
                width="<%= get_icon_size(delivery_point.code == @delivery_point.code) %>"
                height="<%= get_icon_size(delivery_point.code == @delivery_point.code) %>"
              </leaflet-icon>
            </leaflet-marker>
          <% end %>
        </leaflet-map>
        <div class="flex flex-col container px-4 mx-auto w-full max-w-sm h-full">
          <div class="flex flex-col text-center w-full my-4">
            <h1 class="sm:text-3xl text-2xl font-medium title-font text-gray-900">List of PVZ</h1>
            <h2 class="text-xs text-indigo-500 tracking-widest font-medium title-font mb-1">List of PVZ</h2>
          </div>
          <%= f = form_for @delivery_changeset, "#", [class: "w-full"] %>
          <div class="flex mb-2">
            <%= error_wrapper(f, :delivery_point) %>
          </div>
          </form>
          <div class="flex flex-col h-full overflow-y-auto rounded-4xl border-8 border-transparent scroll-smooth">
            <%= for delivery_point <- @delivery_points do %>
              <div
                id="<%= delivery_point.code %>"
                class="py-2"
                phx-click="make_active_delivery_point"
                phx-target="<%= @myself %>"
                phx-value-code="<%= delivery_point.code %>"
              >
                <div class="flex rounded-2xl h-full bg-gray-50 p-4 flex-col <%= bg(delivery_point.code, @active_delivery_point.code, @delivery_point.code)%>">
                  <h2 class="text-gray-900 text-xl title-font font-medium mb-3"><%= delivery_point.name %></h2>
                  <h3 class="text-gray-900 title-font font-medium mb-3"><%= delivery_point.address_full %></h3>
                  <div class="flex-grow">
                    <p class="leading-relaxed text-base"><%= delivery_point.work_time %></p>
                    <p class="leading-relaxed text-base">срок доставки -- <%= @delivery_params[136].period_min %> <%= @delivery_params[136].period_max %> дня</p>
                    <p class="leading-relaxed text-base"><%= @delivery_params[136].delivery_sum %> руб</p>
                  </div>
                  <%= if delivery_point.code == @delivery_point.code do %>
                    <p class="w-full h-16 bg-midnight-500 text-white p-4 rounded-2xl text-center text-xl fron-bold mt-4">
                      Selected
                    </p>
                  <% end %>
                  <%= if (delivery_point.code == @active_delivery_point.code) && (delivery_point.code != @delivery_point.code) do %>
                  <p
                    class="w-full h-16 bg-rose-200 text-main-pink p-4 rounded-2xl text-center text-xl fron-bold mt-4"
                    phx-click="select_delivery_point"
                    phx-target="<%= @myself %>"
                    phx-value-code="<%= delivery_point.code %>"
                  >
                    Select
                  </p>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    """
  end

  @impl true
  def handle_event("select_delivery_point", %{"code" => code} = _params, socket) do
    delivery_point = Enum.find(socket.assigns.delivery_points, &(&1.code == code))
    session_id = socket.assigns.session_id
    ConCache.update(:session_data, session_id, &({:ok, Map.put(&1 || %{}, :delivery_type, :sdek_pickup)}))
    ConCache.update(:session_data, session_id, &({:ok, Map.put(&1 || %{}, :delivery_point, delivery_point)}))
    socket =
      socket

      |> assign(:delivery_point, delivery_point)
      |> push_redirect(to: Routes.order_new_path(socket, :new, [
      ]))
    {:noreply, socket}
  end

  def handle_event("make_active_delivery_point", %{"code" => code} = _params, socket) do
    delivery_point = Enum.find(socket.assigns.delivery_points, &(&1.code == code))
    {:noreply, assign(socket, :active_delivery_point, delivery_point)}
  end

  defp maybe_put_geo_coordinates(%{latitude: nil, longitude: nil} = delivery, []) do
    fias_id = Map.get(delivery, :city_fias_id) || Map.get(delivery, :settlement_fias_id)
    {latitude, longitude} = Suggestions.get_geo_coordinates(fias_id)

    delivery
    |> Map.put(:latitude, latitude)
    |> Map.put(:longitude, longitude)
  end
  defp maybe_put_geo_coordinates(%{latitude: _latitude, longitude: _longitude} = delivery, _), do: delivery
  defp maybe_put_geo_coordinates(delivery, delivery_points) do
    latitudes = Enum.map(delivery_points, &(&1.latitude))
    longitudes = Enum.map(delivery_points, &(&1.longitude))
    delivery_latitude = Enum.sum(latitudes) / length(latitudes)
    delivery_longitude = Enum.sum(longitudes) / length(longitudes)

    delivery
    |> Map.put(:latitude, delivery_latitude)
    |> Map.put(:longitude, delivery_longitude)
  end

  def get_icon_url(true), do: "/images/marker-icon-checked.svg"
  def get_icon_url(_), do: "/images/marker-icon.svg"

  def get_icon_size(true), do: 64
  def get_icon_size(_), do: 48

  defp bg(current_code, active_code, selected_code) do
    case current_code do
      ^selected_code -> "bg-rose-100"
      ^active_code -> "bg-rose-50"
      _ -> ""
    end
  end
  def delivery_points() do
    {:ok, body} = File.read("/Users/ter/projects/new/in_beauty/rostov_list.json")
    Jason.decode!(body, keys: :atoms)
  end
end
