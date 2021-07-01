defmodule InBeautyWeb.OrderLive.New do
  use InBeautyWeb, :live_view
#TODO change cash to mnesia and to save it persistent or to postgres but it is a bit slower not much but
  import Ecto.Query, only: [from: 2]

  alias InBeauty.Repo
  alias InBeauty.Catalogue
  alias InBeauty.Relations
  alias InBeauty.Relations.{StockOrder, StockCart}
  alias InBeauty.Payments
  alias InBeauty.Payments.Order
  alias InBeautyWeb.Forms.OrderFormComponent
  alias InBeauty.Search.Suggestions
  alias InBeauty.Fias
  alias InBeauty.Sdek.Sdek
  alias InBeauty.Deliveries.Delivery
  alias InBeauty.Payments.Cart
  alias InBeautyWeb.InputComponent
  alias InBeauty.Deliveries
  alias Ecto.Multi
  alias InBeauty.Catalogue.ReservedStock

  @rostov %InBeauty.Deliveries.Delivery{
    user: nil,
    private_house: false,
    house_type_full: nil,
    region_type: "обл",
    delivery_type: :sdek_pickup,
    delivery_point: nil,
    date: nil,
    region_type_full: "область",
    city_fias_id: "c1cfe4b9-f7c2-423c-abfa-6ed1c05a15c5",
    settlement: nil,
    area_type_full: nil,
    house: nil,
    region_kladr_id: "6100000000000",
    settlement_type: nil,
    house_kladr_id: nil,
    area_type: nil,
    updated_at: nil,
    longitude: 39.718705,
    order_id: nil,
    street_type: nil,
    street_fias_id: nil,
    settlement_type_full: nil,
    area: nil,
    area_kladr_id: nil,
    house_fias_id: nil,
    status: nil,
    street: nil,
    city_kladr_id: "6100000100000",
    street_type_full: nil,
    flat_type_full: nil,
    region: "Ростовская",
    sdek_city_code: 438,
    city_type_full: "город",
    flat_fias_id: nil,
    city_type: "г",
    house_type: nil,
    id: nil,
    latitude: 47.222531,
    city: "Ростов-на-Дону",
    city_district_kladr_id: nil,
    settlement_fias_id: nil,
    inserted_at: nil,
    flat: nil,
    order: nil,
    user_id: nil,
    flat_type: nil,
    area_fias_id: nil,
    region_fias_id: "f10763dc-63e3-48db-83e1-9c566fe3092b",
    settlement_kladr_id: nil
  }

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)
    user = socket.assigns.current_user
    session_id = session["session_id"]
    cart_query = from s in StockCart, order_by: s.volume
    cart =
      socket.assigns.current_cart
      |> Repo.preload(stocks_carts: {cart_query, [stock: [:product]]})
      |> Payments.add_cart_attrs()

    order =
      case user && user.id do
        nil ->
          %Order{}
        _ ->
          %Order{
            first_name: user.first_name,
            last_name: user.last_name,
            email: user.email,
            phone_number: user.phone_number
          }
      end
      |> Map.put(:status, "created")
      |> Map.put(:product_price, cart.total_price)
      |> Payments.change_order()

    socket =
      socket
      |> assign(:page_title, "Create Order")
      |> assign(:changeset, order)
      |> assign(:step, 1)
      |> assign(:session_id, session_id)
      |> assign(:current_cart, cart)
      |> assign(:suggestions, [])
      |> assign(:fields, [:first_name, :last_name, :email, :phone_number])
      |> assign(:required_fields, [:first_name, :last_name, :email, :phone_number])
      |> assign(:delivery_changeset, nil)

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    session_id = socket.assigns.session_id
    socket =
      socket
      |> put_delivery()
      #TODO make logic of persistent delivery_type may be add all in one paramsa
      |> put_delivery_points()
      |> put_delivery_point()
      |> put_delivery_params()
      |> apply_action(socket.assigns.live_action, params)
    {:noreply, socket}
  end

  defp apply_action(socket, :new, params) do
    socket
  end

  # defp apply_action(socket, :map, params) do
  #   socket
  # end

  defp apply_action(socket, :search, params) do
    socket
  end

  defp apply_action(socket, action, params) when action in [:courier, :map] do

    if socket.assigns.delivery_changeset do
      socket
    else
      delivery_changeset =
        socket.assigns.delivery
        |> Delivery.changeset()
        |> Map.put(:action, :update)
      assign(socket, :delivery_changeset, delivery_changeset)
    end
  end

  def handle_event("validate", %{"order" => order_params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> Payments.change_order(order_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("change_delivery_type", %{"type" => delivery_type}, socket) do
    #TODO may be caset innchangeset changing delivery_type
    session_id = socket.assigns.session_id
    delivery_type = String.to_atom(delivery_type)
    delivery = Map.put(socket.assigns.delivery, :delivery_type, delivery_type)
    ConCache.update(:session_data, session_id, &({:ok, Map.put(&1 || %{}, :delivery, delivery)}))
    {:noreply, assign(socket, :delivery, delivery)}
  end

  def handle_event("save", _, socket) do
    session_id = socket.assigns.session_id
    cached_data = ConCache.get(:session_data, session_id)
    delivery_point = cached_data[:delivery_point]
    delivery_params = cached_data[:delivery_params]
    delivery = socket.assigns.delivery
    cart_query = from s in StockCart, order_by: s.volume
    order_changeset =
      socket.assigns.changeset
      |> Map.put(:errors, [])
      |> Map.put(:valid?, true)

    cart =
      socket.assigns.current_cart
      |> Repo.preload(stocks_carts: {cart_query, [stock: [:product]]})
      |> Payments.add_cart_attrs()

    reserved_stocks_params = Enum.map(cart.stocks_carts, &(Map.take(&1,[:quantity, :stock_id, :volume])))
      delivery_params =
        case delivery.delivery_type in [:sdek_pickup, :in_beauty_pickup] do
          true ->
            delivery_params[136]
          _ ->
            delivery_params[137]
        end

    order_params =
      if socket.assigns.current_user do
         %{"user_id" =>  socket.assigns.current_user.id}
      else
        %{}
      end
      |> Map.put("product_price", cart.total_price + 0.1)
      |> Map.put("total_price", cart.total_price + delivery_params.delivery_sum)
      |> Map.put("status", "created")

      delivery =
        delivery
        |> Map.put(:price, delivery_params.delivery_sum)
        |> Map.put(:period_min, delivery_params.period_min)
        |> Map.put(:period_max, delivery_params.period_max)
      # |> Map.put("reserved_stocks", reserved_stocks_params)

      #TODO stock_cart_changesets must be checked at first and notify user that counts of proudcts changed
      stock_cart_changesets = Relations.verify_stocks_carts(cart.stocks_carts)
      order_changeset = Payments.change_order(order_changeset, order_params)
      # |> InBeauty.Repo.insert()
      multi =
        Ecto.Multi.new()
        |> Ecto.Multi.insert(:order, order_changeset )
        |> Ecto.Multi.insert(:delivery, fn %{order: order} ->
          Deliveries.create_change_delivery(delivery, %{delivery_point: delivery_point, order_id: order.id})
        end)
        |> Ecto.Multi.insert_all(:reserved_stocks, ReservedStock, fn %{order: order} ->
          reserved_stocks_params
          |> Enum.map(fn reserved_stock_param ->
            Map.put(reserved_stock_param, :order_id, order.id)
            |> Map.put(:inserted_at, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
            |> Map.put(:updated_at, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
          end)
        end)

      Enum.reduce(cart.stocks_carts, multi, fn stock_cart, multi ->
        Multi.update(
          multi,
          {:stock, stock_cart.stock.id},
          Catalogue.change_stock(stock_cart.stock, %{quantity: stock_cart.stock.quantity - stock_cart.quantity})
        )
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{order: order, reserved_stocks: reserved_stocks} = all_params} ->
          # Operation was successful, we can access results (exactly the same
          # we would get from running corresponding Repo functions) under keys
          # we used for naming the operations.
          socket =
            socket
            |> put_flash(:info, "Order Created")
            |> push_redirect(to: Routes.order_second_step_path(socket, :step_2, order.id))
          {:noreply, socket}
        {:error, :delivery, delivery_changeset, _} ->
          IO.inspect(" i am in delivery error")
          error_field =
            delivery_changeset.errors
            |> Enum.reduce(nil, fn {field,_}, acc ->
              if field in [:street, :house, :flate, :date, :delivery_point] do
                field
              else
                acc
              end
            end)
          socket = redirect_by_errors(socket, error_field)
          {:noreply, assign(socket, :delivery_changeset, Map.put(delivery_changeset, :action, :update))}
        {:error, :order, order_changeset, changes_so_far} ->
          IO.inspect(order_changeset, label: " i am in order error")
          {:noreply, assign(socket, :changeset, order_changeset)}
        {:error, failed_operation, failed_value, changes_so_far} ->
          IO.inspect({failed_operation, failed_value}, label: "i am in all errors")
          # One of the operations failed. We can access the operation's failure
          # value (like changeset for operations on changesets) to prepare a
          # proper response. We also get access to the results of any operations
          # that succeeded before the indicated operation failed. However, any
          # successful operations would have been rolled back.
          {:noreply, socket}
      end

      # delivery =
      #   case Deliveries.create_delivery(delivery, %{delivery_point: delivery_point}) do
      #     {:ok, delivery} ->
      #       order_changeset = Payments.change_order(order_changeset, order_params)
      #       proceed_order_creation(socket, order_changeset, delivery)
      #     {:error, delivery_changeset} ->
      #       error_field =
      #         delivery_changeset.errors
      #         |> Enum.reduce(nil, fn {field,_}, acc ->
      #           if field in [:street, :house, :flate, :date, :delivery_point] do
      #             field
      #           else
      #             acc
      #           end
      #         end)
      #       socket = redirect_by_errors(socket, error_field)
      #       {:noreply, assign(socket, :delivery_changeset, Map.put(delivery_changeset, :action, :update))}
      #   end
  end

  defp proceed_order_creation(socket, changeset, delivery) do
    case Payments.create_order(changeset, %{}) do
      {:ok, order} ->
        # delivery = Deliveries.create_delivery(delivery)
        socket =
          socket
          |> put_flash(:info, "Order Created")
          |> push_redirect(to: Routes.order_second_step_path(socket, :step_2, order.id))
        Deliveries.update_delivery(delivery, %{order_id: order.id, delivery_point: delivery.delivery_point})
        {:noreply, socket}
      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def redirect_by_errors(socket, error_field) when error_field in [:street, :house, :flate, :date] do
    push_patch(socket, to: Routes.order_new_path(socket, :courier))
  end
  def redirect_by_errors(socket, error_field) when error_field in [:delivery_point] do
    push_patch(socket, to: Routes.order_new_path(socket, :map))
  end
  def redirect_by_errors(socket, _) do
    socket
  end

  def handle_info({update_delivery, %{delivery: delivery, delivery_points: delivery_points, delivery_params: delivery_params}}, socket) do
    socket =
      socket
      |> assign(:delivery, delivery)
      |> assign(:delivery_points, delivery_points)
      |> assign(:delivery_params, delivery_params)
    {:noreply, socket}
  end

  def handle_info({:update_delivery, %{delivery: delivery}}, socket) do
    socket =
      socket
      |> assign(:delivery, delivery)
      |> assign(:delivery_changeset, Delivery.changeset(delivery))
    {:noreply, socket}
  end

  def handle_info({Payments, [:order, :updated], _}, socket) do
    query = from s in StockOrder, order_by: s.volume

    order =
      socket.assigns.current_order.id
      |> Payments.get_order!()
      |> Repo.preload(stocks_orders: {query, [stock: [:product]]})

    order = Payments.add_order_attrs(order.stocks_orders, order)
    {:noreply, assign(socket, :order, order)}
  end

  defp put_delivery(socket) do
    session_id = socket.assigns.session_id
    cached_data = ConCache.get(:session_data, session_id)
    delivery = cached_data[:delivery]
    if delivery do
      assign(socket, :delivery, delivery)
    else
      assign(socket, :delivery, @rostov)
    end
  end

  # Returns socket with delivery_points in asigns. Nothing do if delivery_points are already in assigns.
  defp put_delivery_points(%{assigns: %{delivery_points: delivery_points}} = socket) when delivery_points != nil, do: socket
  defp put_delivery_points(socket) do
    session_id = socket.assigns.session_id
    cached_data = ConCache.get(:session_data, session_id)
    delivery_points = cached_data[:delivery_points]
    city_code = socket.assigns.delivery.sdek_city_code

    if delivery_points do
      assign(socket, :delivery_points, delivery_points)
    else
      case Sdek.get_delivery_points(city_code) do
        {:ok, delivery_points} ->
          ConCache.update(:session_data, session_id, &({:ok, Map.put(&1 || %{}, :delivery_points, delivery_points)}))
          assign(socket, :delivery_points, delivery_points)
        _ ->
          assign(socket, :delivery_points, [])
      end
    end
  end
  defp put_delivery_points(socket), do: assign(socket, :delivery_points, [])

  defp put_delivery_point(%{assigns: %{delivery_points: []}} = socket), do: assign(socket, :delivery_point, %InBeauty.Deliveries.DeliveryPoint{})
  defp put_delivery_point(%{assigns: %{delivery_points: delivery_points}} = socket) do
    session_id = socket.assigns.session_id
    cached_data = ConCache.get(:session_data, session_id)
    delivery_point = cached_data[:delivery_point] || %InBeauty.Deliveries.DeliveryPoint{}
    delivery_point = Enum.find(delivery_points, &(&1.code == delivery_point.code))
    if delivery_point do
      assign(socket, :delivery_point, delivery_point)
    else
      assign(socket, :delivery_point, %InBeauty.Deliveries.DeliveryPoint{})
    end
  end

  defp put_delivery_params(%{assigns: %{delivery_points: []}} = socket), do: assign(socket, :delivery_params, nil)
  defp put_delivery_params(%{assigns: %{delivery_params: delivery_params}} = socket) when is_map(delivery_params), do: socket
  defp put_delivery_params(socket) do
    session_id = socket.assigns.session_id
    cached_data = ConCache.get(:session_data, session_id)
    delivery_params = cached_data[:delivery_params]
    city_code = socket.assigns.delivery.sdek_city_code

    if delivery_params do
      assign(socket, :delivery_params, delivery_params)
    else
      case Sdek.calculate_deliveries(city_code) do
        {:ok, delivery_params} ->
          ConCache.update(:session_data, session_id, &({:ok, Map.put(&1 || %{}, :delivery_params, delivery_params)}))
          assign(socket, :delivery_params, delivery_params)
        {:error, _} ->
          assign(socket, :delivery_params, nil)
      end
    end
  end

  def active?(step, i) do
    if step == i,
      do: "bg-rose-300 dark:bg-rose-100 dark:text-main-pink",
      else: "bg-rose-100 dark:bg-midnight-500"
  end
  def active_delivery_type?(selected_type, type) do
    if selected_type == type,
      do: " bg-rose-200 ring-4 ring-offset-4 ring-rose-200",
      else: ""
  end
end
