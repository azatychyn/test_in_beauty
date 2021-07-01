defmodule InBeautyWeb.CartLive.Show do
  use InBeautyWeb, :live_view

  import Ecto.Query
  alias InBeauty.Repo
  alias InBeauty.Catalogue
  alias InBeauty.Relations
  alias InBeauty.Relations.StockCart
  alias InBeauty.Payments
  alias InBeautyWeb.Forms.ProductImageComponent

  # alias InBeauty.Catalogue.{Product, Stock, Review}
  # alias InBeautyWeb.Forms.ProductFormComponent
  # alias InBeautyWeb.InputComponent
  # alias InBeauty.Repo

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)
    id = socket.assigns.current_cart.id
    if connected?(socket), do: Payments.subscribe(id)

    query = from s in StockCart, order_by: s.volume
    cart =
      id
      |> Payments.get_cart!()
      |> Repo.preload([stocks_carts: {query, [stock: [:product]]}])
      |> Payments.add_cart_attrs()

      socket =
        socket
        |> assign(:page_title, "Cart")
        |> assign(:cart, cart)
    {:ok, socket}
  end


  def handle_event("inc", %{"id" => id}, socket) do
    id
    |> update_stock(1)
    |> respond_type(socket)
  end

  def handle_event("dec", %{"id" => id}, socket) do
    id
    |> update_stock(-1)
    |> respond_type(socket)
  end


  def handle_event("remove_from_cart", %{"id" => id}, socket) do
    stock_cart = Relations.get_stock_cart!(id)

    case Relations.delete_stock_cart(stock_cart) do
      {:ok, _} ->
        #notify subscribes to update the cart
        Payments.notify_subscribers({:ok, socket.assigns.current_cart}, [:cart, :updated])
        {:noreply, put_flash(socket, :info, "Product was successfully deleted from cart")}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Error, can't delete product from cart, try again")}
    end
    {:noreply, socket}
  end

  defp update_stock(id, value) do
    stock_cart = Relations.get_stock_cart!(id) |> Repo.preload([:stock])

    with  true <- (stock_cart.quantity + value) > 0,
          true <- stock_cart.quantity < stock_cart.stock.quantity,
          {:ok, stock_cart_updated} <- Relations.update_stock_cart(stock_cart, %{quantity: stock_cart.quantity + value})
    do
      Payments.notify_subscribers({:ok, %{id: stock_cart.cart_id}}, [:cart, :updated])
      {:ok, :cart}
    else
      nil ->
        {:error, :delteted_stock_cart_error}
      {:error, %Ecto.Changeset{} = changeset} ->
        #TODO in future if should be error be shown and parsed from changeset
          {:error, nil}
      false ->
        {:error, :zero_down_quantity_error}
      _ ->
        {:error, nil}
    end
  end

  defp respond_type({:ok, :cart}, socket) do
    # {:noreply, assign(socket, :cart, cart)}
    {:noreply, socket}
  end
  defp respond_type({:error, :delteted_stock_cart_error}, socket) do
    socket =
      socket
      |> put_flash(:error, "Error, Product was deleted from cart, try again")
      |> push_redirect(to: Routes.cart_show_path(socket, :show, socket.assigns.current_cart))

    {:noreply, socket}
  end
  defp respond_type({:error, :zero_down_quantity_error}, socket) do
    socket =
      socket
      |> put_flash(:error, "Can not add or remove more")

    {:noreply, socket}
  end
  defp respond_type({:error, _}, socket) do
    socket =
      socket
      |> put_flash(:error, "Error, can't update the cart, try again")
      |> push_redirect(to: Routes.cart_show_path(socket, :show, socket.assigns.current_cart.id))

    {:noreply, socket}
  end

  def handle_info({Payments, [:cart, :updated], _}, socket) do
    query = from s in StockCart, order_by: s.volume
    cart =
      socket.assigns.current_cart.id
      |> Payments.get_cart!()
      |> Repo.preload([stocks_carts: {query, [stock: [:product]]}])
      |> Payments.add_cart_attrs()
    {:noreply, assign(socket, :cart, cart)}
  end
end
