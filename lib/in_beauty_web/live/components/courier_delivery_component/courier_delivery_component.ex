defmodule InBeautyWeb.CourierDeliveryComponent do
  @moduledoc """

  	<%= live_component(@socket, SearchComponent,
  				required_fields: [:first_name, :last_name],
  				fields: [:first_name, :last_name],
  				button_text: "Sigh up",
  				live_action: "sight_up",
  				id_prefix: "sign_up",
  				mobile: false
  	)
  	%>
  """

  use InBeautyWeb, :live_component

  alias InBeauty.Search.Suggestions
  alias InBeauty.Fias
  alias InBeauty.Sdek.Sdek
  alias InBeauty.Deliveries.Delivery

  @defaults %{
    fields: [],
    live_action: "",
    form_action: "#",
    handle_events: [],
    id_prefix: "",
    mobile: false,
    error: nil,
    street_suggestions: [],
    house_suggestions: [],
    flat_suggestions: [],
    search_query: ""
  }

  @steps [:street, :house, :flat, :date]
  @impl Phoenix.LiveComponent
  def mount(socket) do
    socket =
      socket
      |> assign(:step, :step_1)
      |> assign(@defaults)

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    private_house = get_changeset_field(assigns.delivery_changeset, :private_house)

    socket =
      socket
      |> assign(:private_house, private_house)
      |> assign(assigns)

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("select_date", %{"delivery" => %{"date" => date}}, socket) do
    date = Date.from_iso8601!(date)
    delivery_changeset = socket.assigns.delivery_changeset
    updated_delivery_changeset = Delivery.changeset(delivery_changeset, %{"date" => date})
    {:noreply, assign(socket, :delivery_changeset, updated_delivery_changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle_private_house", _, socket) do
    delivery_changeset = Delivery.private_house_changeset(socket.assigns.delivery_changeset)
    private_house = get_changeset_field(delivery_changeset, :private_house)

    socket =
      socket
      |> assign(:delivery_changeset, delivery_changeset)
      |> assign(:private_house, private_house)

    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("search_street", %{"delivery" => %{"street" => ""}}, socket) do
    {:noreply, assign(socket, :street_suggestions, [])}
  end

  @impl Phoenix.LiveComponent
  def handle_event("search_street", %{"delivery" => %{"street" => street}}, socket) do
    suggestions_by_field(socket, "street", street)
  end

  @impl Phoenix.LiveComponent
  def handle_event("search_house", %{"delivery" => %{"house" => ""}}, socket) do
    {:noreply, assign(socket, :house_suggestions, [])}
  end

  @impl Phoenix.LiveComponent
  def handle_event("search_house", %{"delivery" => %{"house" => house}}, socket) do
    suggestions_by_field(socket, "house", house)
  end

  @impl Phoenix.LiveComponent
  def handle_event("search_flat", %{"delivery" => %{"flat" => ""}}, socket) do
    {:noreply, assign(socket, :flat_suggestions, [])}
  end

  @impl Phoenix.LiveComponent
  def handle_event("search_flat", %{"delivery" => %{"flat" => flat}}, socket) do
    suggestions_by_field(socket, "flat", flat)
  end

  def handle_event("update_street", %{"i" => i}, socket),
    do: update_field(:street_suggestions, i, socket)

  def handle_event("update_house", %{"i" => i}, socket),
    do: update_field(:house_suggestions, i, socket)

  def handle_event("update_flat", %{"i" => i}, socket),
    do: update_field(:flat_suggestions, i, socket)

  def handle_event("save",_, socket) do
    delivery_changeset = socket.assigns.delivery_changeset
    session_id = socket.assigns.session_id
    cached_data = ConCache.get(:session_data, session_id)

    params = %{
      "delivery_type" =>  "sdek_courier"
    }
    delivery_changeset =
      delivery_changeset
      |> Delivery.final_changeset(params)
      |> Map.put(:action, :update)

    case delivery_changeset.valid? do
      true ->
        delivery = Delivery.from_changeset_to_struct(delivery_changeset)
        ConCache.update(
          :session_data,
          session_id,
          &{:ok, Map.put(&1 || %{}, :delivery, delivery)}
        )

        send(self(), {:update_delivery, %{
          delivery: delivery
        }})
        {:noreply, push_patch(socket, to: Routes.order_new_path(socket, :new))}

      _ ->
        {:noreply, assign(socket, :delivery_changeset, delivery_changeset)}
    end
  end

  def suggestions_by_field(socket, field, field_value) do
    field_value = String.trim(field_value)
    delivery = socket.assigns.delivery_changeset.data

    delivery_changeset =
      delivery
      |> InBeauty.Deliveries.Delivery.changeset(%{field => field_value}, field)
      |> Map.put(:action, :update)

    location =  get_location(delivery, field)

    suggestions =
      cond do
        field_value == "" ->
          []

        delivery_changeset.valid? ->
          search_params = %{
            from_bound: %{value: field},
            to_bound: %{value: field},
            locations: [
              location
            ],
            query: field_value
          }

          case Suggestions.find(search_params) do
            {:error, _} -> [%{delivery | "#{field}": field_value, "#{field}_type": get_field_type(field)}]
            [] -> [%{delivery | "#{field}": field_value, "#{field}_type": get_field_type(field)}]
            suggestions -> suggestions
          end

        delivery_changeset.valid? == false ->
          :error
      end

    socket =
      socket
      |> put_suggestions_by_field(field)
      |> assign(:"#{field}_suggestions", suggestions)
      |> assign(:delivery_changeset, delivery_changeset)
      |> assign(:search_query, field_value)

    {:noreply, socket}
  end

  def put_suggestions_by_field(socket, field) do
    Enum.reduce(["street", "flat", "house"], socket, fn cur_field, acc ->
      if cur_field == field do
        acc
      else
        assign(acc, :"#{cur_field}_suggestions", nil)
      end
    end)
  end

  defp update_field(field_suggestions, index, socket) do
    suggestions = Map.get(socket.assigns, field_suggestions)
    index = String.to_integer(index)
    delivery = Enum.at(suggestions, index)
    delivery_changeset = Delivery.changeset(delivery)

    socket =
      socket
      |> assign(:delivery_changeset, delivery_changeset)
      |> assign(:"#{field_suggestions}", nil)

    {:noreply, socket}
  end

  defp get_location(delivery, "house"), do: Map.take(delivery, [:street_fias_id])
  defp get_location(delivery, "flat"), do: Map.take(delivery, [:house_fias_id])
  defp get_location(delivery, _),
    do: Map.take(delivery, [:city_fias_id]) || Map.take(delivery, [:settlement_fias_id])

  defp get_field_type("street"), do: "ул"
  defp get_field_type("house"), do: "д"
  defp get_field_type(_), do: "кв"

  def date_variants() do
    for i <- 1..7 do
      get_date_by_add(i)
    end
  end

  def get_date_by_add(index), do: Date.add(Date.utc_today(), index)
end
