defmodule InBeautyWeb.OrderLive.SecondStep do
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
  alias InBeauty.Catalogue.ReservedStock

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, session, socket) do
    #TODO may be check if it payed
    socket = assign_defaults(socket, session)
    session_id = session["session_id"]
    order =
      id
      |> Payments.get_order!()
      |> Repo.preload([:delivery, reserved_stocks: [stock: [:product]]])
      |> IO.inspect()

    user = socket.assigns.current_user
    allow_cash? =
      if order.delivery.delivery_type in [:in_beauty_pickup, :sdek_pickup] do
        true
      else
        false
      end

    socket =
      socket
      |> assign(:page_title, "Create Order")
      |> assign(:order, order)
      |> assign(:step, 2)
      |> assign(:session_id, session_id)
      |> assign(:delivery_changeset, nil)
      |> assign(:allow_cash?, allow_cash?)

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    socket =
      socket
      |> apply_action(socket.assigns.live_action, params)
    {:noreply, socket}
  end

  defp apply_action(socket, _, params) do
    socket
  end



  def handle_event("save", _, socket) do
    order = socket.assigns.order |> Repo.preload([:user, :stocks_orders, :stocks])

    stocks_orders_params =
      Enum.map(order.reserved_stocks, fn reserved_stock ->
        reserved_stock
        |> Map.take([:quantity, :stock_id, :volume, :order_id])
        # |> Map.put(:inserted_at, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
        # |> Map.put(:updated_at, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
      end)

    order_params = %{"status" => "payment_on_delivery", "user_id" => order.user_id}
    order_changeset = Payments.change_order(order, order_params)
      # |> InBeauty.Repo.insert()
      multi =
        Ecto.Multi.new()
        |> Ecto.Multi.update(:order, order_changeset )
        |> Ecto.Multi.delete_all(:reserved_stocks, fn %{order: order} ->
            ReservedStock |> Ecto.Query.where(order_id: ^order.id)

        end)
        |> Ecto.Multi.insert_all(:stocks_orders, StockOrder, stocks_orders_params)
        |> Repo.transaction()
        |> case do
          {:ok, %{order: order} = all_params} ->
            # Operation was successful, we can access results (exactly the same
            # we would get from running corresponding Repo functions) under keys
            # we used for naming the operations.
            socket =
              socket
              |> put_flash(:info, "Order updated")
              |> assign(:order, order)
            {:noreply, socket}
          {:error, :delivery, delivery_changeset, _} ->
            IO.inspect(" i am in delivery error")
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
  def active?(step, i) do
    if step == i,
      do: "bg-rose-300 dark:bg-rose-100 dark:text-main-pink",
      else: "bg-rose-100 dark:bg-midnight-500"
  end

  def split_flaot(float) do
    float
    |> :erlang.float_to_binary([decimals: 2])
    |> String.split(".")
  end
end
