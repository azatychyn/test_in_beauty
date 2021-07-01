defmodule InBeautyWeb.SearchComponent do
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
  alias InBeauty.Sdek.Sdek
	alias InBeauty.Deliveries.Delivery

  @defaults %{
    fields: [],
    live_action: "",
    form_action: "#",
    handle_events: [],
    id_prefix: "",
    mobile: false,
		suggestions: [],
		desired_city: nil,
		manual_suggestions: [],
		search_query: "",
		error: nil
  }

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, @defaults)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~L"""
		<div class="flex">
			<div class="grid grid-cols-2 gap-4 w-1/2 px-2 mb-12 ">
				<div class="bg-rose-100 w-full rounded-2xl flex items-center justify-around h-32">
					<div class="flex">
						<div class="w-12 h-12">
							<%= InBeautyWeb.IconView.render(InBeautyWeb.IconView, "library.html") %>
						</div>
						<div class="ml-4">
							<p class="text-md uppercase text-pink-dark-dribble flex font-bold">
								<%= gettext("город") %>:
							</p>
							<p class="flex items-center justify-center text-2xl text-gray-700 font-semibold leading-tight mr-4">
								<%= if @desired_city do %>
									<%= @desired_city.city || @desired_city.settlement %>
								<% else %>
									<%= @delivery.city || @delivery.settlement %>
								<% end %>
							</p>
						</div>
					</div>
				</div>
				<div class="bg-rose-100 w-full rounded-2xl flex items-center justify-around h-32">
					<div class="flex">
						<div class="w-12 h-12">
							<%= InBeautyWeb.IconView.render(InBeautyWeb.IconView, "location.html") %>
						</div>
						<div class="ml-4">
							<p class="text-md uppercase text-pink-dark-dribble flex font-bold">
								<%= gettext("область") %>:
							</p>
							<p class="flex items-center justify-center text-2xl text-gray-700 font-semibold leading-tight mr-4">
								<%= @delivery.region || @delivery_changeset.area %>
							</p>
						</div>
					</div>
				</div>
				<!-- city-->
				<div class="w-full col-span-full">
					<div class="bg-rose-100 p-4 rounded-2xl">
						<div class="text-2xl font-bold text-main-pink block mb-3 ml-1  tracking-widest">
							Город
						</div>
						<%= live_component(@socket, InBeautyWeb.InputSelectComponent,
									variants: @suggestions,
									field: :desire_city,
									changeset: @delivery_changeset,
									handle_events: [phx_change: :search],
									target: @myself,
									wrapper_size: "w-20 md:w-96 h-20 md:h-28",
									device: @device
								)
						%>
					</div>
				</div>
				<%= if @error do %>
					<div class="w-full col-span-full rounded-2xl p-8 py-8 bg-rose-400 text-2xl text-white"> <%= @error %></div>
				<% end %>
				<!-- STREET DROPDOWN -->
				<%= case @suggestions in ["", [], [""], :error, nil] do %>
				<% true -> %>
				<% _ -> %>
					<div class="bg-rose-100 col-span-full rounded-2xl p-4 slide-right">
						<ol class="w-full flex flex-col bg-white dark:bg-denim-500 rounded-2xl">
							<%= for {variant, i} <- Enum.with_index(@suggestions) do %>
								<li
										phx-target="<%= @myself %>"
										phx-click="update_delivery"
										phx-value-i="<%= i %>"
										class=" flex hover:bg-rose-100 cursor-pointer"
									>
									<div class="flex px-4 py-1 text-xl text-gray-700 dark:text-gray-100">
										<p>
											<%= "
												#{variant.settlement_type && variant.settlement_type <> "."}
												#{variant.settlement && variant.settlement <> ","}
												#{variant.city_type && variant.city_type <> "."}
												#{variant.city && variant.city <> ","}
												#{variant.area_type && variant.area_type <> ". "}
												#{variant.area && variant.area <> ","}
												#{variant.region_type && variant.region_type <> ". "}
												#{variant.region && variant.region}
											" %>
										</p>
									</div>
								</li>
							<% end %>
						</ol>
					</div>
				<% end %>
			</div>
			<div class="w-full h-full bg-rose-100 flex flex-wrap rounded-2xl p-2 transform overflow-hidden relative">
				<div class=" absolute top-12 w-max h-full bg-rose-100 grid grid-cols-6 grid-flow-row rounded-2xl p-2 transform">
				<%= for i <- 1.. 40 do %>
					<p class=" px-4 py-2 text-9xl tracking-widest">INBEAUTY</p>
				<% end %>
				</div>
			</div>
		</div>
    """
  end

	@impl Phoenix.LiveComponent
  def handle_event("search",  %{"delivery" => %{"desire_city" => ""}}, socket) do
		{:noreply, assign(socket, :suggestions, [])}
  end
  def handle_event("search", %{"delivery" => %{"desire_city" => query}}, socket) do
		query = String.trim(query)
		delivery = socket.assigns.delivery

    search_params = %{
      from_bound: %{value: "city"},
      to_bound: %{value: "settlement"},
      query: query
    }

		delivery_changeset =
      delivery
      |> InBeauty.Deliveries.Delivery.changeset(%{}, "city")
      |> Map.put(:action, :update)

    suggestions =
      cond do
        query == "" ->
          []

        delivery_changeset.valid? ->
          case Suggestions.find(search_params) do
            {:error, _} ->
							[
								%Delivery{}
								|> Map.put(:city, query)
							]
            [] ->
							[
								%Delivery{}
								|> Map.put(:city, query)
							]
            suggestions -> suggestions
          end

        delivery_changeset.valid? == false ->
          :error
      end

		socket =
			socket
			|> assign(:suggestions, suggestions)
			|> assign(:delivery_changeset, delivery_changeset)
			|> assign(:search_query, query)
		{:noreply, socket}
  end

  def handle_event("update_delivery", %{"i" => index}, socket) do
    suggestions = socket.assigns.suggestions
    index = String.to_integer(index)
    session_id = socket.assigns.session_id

    delivery =
      suggestions
      |> Enum.at(index)
      |> put_sdek_city_code()

    delivery_points = get_delivery_points(delivery.sdek_city_code)
    delivery_params = get_delivery_params(delivery.sdek_city_code)

    if delivery_points == [] do
      socket =
        socket
        |> assign(:error, "Приносим извинения, доставка в выбранный город временно недоступна. Выберите пожалуйста другой город")
        |> assign(:desired_city, delivery)
        |> assign(:suggestions, nil)
      {:noreply, socket}
    else
			ConCache.update(:session_data, session_id, &({:ok, Map.put(&1 || %{}, :delivery, delivery)}))
			ConCache.update(:session_data, session_id, &({:ok, Map.put(&1 || %{}, :delivery_points, delivery_points)}))
			ConCache.update(:session_data, session_id, &({:ok, Map.put(&1 || %{}, :delivery_params, delivery_params)}))

			send(self(), {:update_delivery, %{
				delivery: delivery,
				delivery_points: delivery_points,
				delivery_params: delivery_params
			}})
      {:noreply, push_patch(socket, to: Routes.order_new_path(socket, :new))}
    end
  end

  defp get_delivery_params(city_code) do
    case Sdek.calculate_deliveries(city_code) do
      {:ok, delivery_params} ->
        delivery_params
      {:error, _} ->
        nil
    end
  end

  defp get_delivery_points(city_id) do
    case Sdek.get_delivery_points(city_id) do
      {:ok, delivery_points} ->
        delivery_points
      _ ->
        []
    end
  end

	defp put_sdek_city_code(delivery) do
    fias_id = Map.get(delivery, :city_fias_id) || Map.get(delivery, :settlement_fias_id)
    kladr_id = Map.get(delivery, :city_kladr_id) || Map.get(delivery, :settlement_kladr_id)

    # TODO тут критическая ошибкка если сдек возращает {:error, nil}
    city_code = Suggestions.search_city_code(fias_id, kladr_id)
    Map.put(delivery, :sdek_city_code, city_code)
  end

  defp margin_left?(nil), do: ""
  defp margin_left?(_), do: "ml-2"
end
