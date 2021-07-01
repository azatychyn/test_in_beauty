defmodule InBeautyWeb.ProductLive.Show do
  use InBeautyWeb, :live_view

  alias InBeauty.Catalogue
  alias InBeauty.Relations
  alias InBeautyWeb.Forms.ProductImageComponent
  # alias InBeauty.Catalogue.{Product, Stock, Review}
  # alias InBeautyWeb.Forms.ProductFormComponent
  # alias InBeautyWeb.InputComponent
  # alias InBeauty.Repo

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign_defaults(session)


    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _url, socket) do
    product = Catalogue.get_product!(id)
    stock = List.first(product.stocks)
    cart_id = socket.assigns.current_cart.id
    stock_cart = Relations.get_stock_cart_by([stock_id: stock.id, cart_id: cart_id, volume: stock.volume])
    favorite = favorite_product?(product.carts_products, product.id)

    if connected?(socket), do: Catalogue.subscribe(product.id)
    socket
    |> assign(:page_title, "Product - #{product.name}")
    |> assign(:product, product)
    |> assign(:selected_stock, stock)
    |> assign(:stock_cart, stock_cart)
    |> assign(:quantity, @stock_cart["quantity"] || 1)
    |> assign(:favorite, favorite)
    |> apply_action(socket.assigns.live_action, params)
  end

  defp apply_action(socket, :show, params) do
    {:noreply, socket}
  end
  defp apply_action(socket, :image, %{"path" => path}) do
    {:noreply, socket}
  end

  def handle_event("select_stock",  %{"id" => id}, socket) do
    stock = Enum.find(socket.assigns.product.stocks, &(&1.id == id))
    cart_id = socket.assigns.current_cart.id
    stock_cart = Relations.get_stock_cart_by([stock_id: stock.id, cart_id: cart_id, volume: stock.volume])

    socket =
      socket
      |> assign(:selected_stock, stock)
      |> assign(:stock_cart, stock_cart)
      |> assign(:quantity, @stock_cart["quantity"] || 1)

    {:noreply, socket}
  end

  def handle_event("add_to_cart",  _, socket) do
    cart_id = socket.assigns.current_cart.id
    # this will reise error if stock not in database
    stock = Catalogue.get_stock!(socket.assigns.selected_stock.id)

    stock_cart_params = %{
      cart_id: cart_id,
      stock_id: stock.id,
      volume: stock.volume,
      quantity: 1
    }

    case 1 <= stock.quantity do
      true ->
        # this will reise error if stock_cart haven't been created
        # TODO may be do second step to show what error in there maybe already in cart of message to reload the page
        {:ok, stock_cart} = Relations.create_stock_cart(stock_cart_params)
        socket =
          socket
          |> assign(:stock_cart, stock_cart)
          |> put_flash(:info, "Product added to cart")

        {:noreply, socket}
      false ->
        socket =
          socket
          |> put_flash(:error, "There are only #{stock.quantity} in stock")
        {:noreply, socket}
    end
  end

  def handle_event("add_more",  _, socket) do
    stock = Catalogue.get_stock!(socket.assigns.selected_stock.id)
    #TODO May be not to fetcj or to update its valuse in one query
    #this will reise error if can't fetch
    stock_cart = Relations.get_stock_cart!(socket.assigns.stock_cart.id)

    case stock_cart.quantity < stock.quantity do
      true ->
        {:ok, updated_stock_cart} = Relations.update_stock_cart(stock_cart, %{quantity: stock_cart.quantity + 1})
        socket =
          socket
          |> assign(:stock_cart, updated_stock_cart)
          |> put_flash(:info, "Product added to cart")

        {:noreply, socket}
      false ->
        socket =
          socket
          |> put_flash(:error, "There are only #{stock.quantity} in stock")
        {:noreply, socket}
    end
  end

  def handle_event("add_to_favorite",  _, socket) do
    product = socket.assigns.product
    cart_id = socket.assigns.current_cart.id

    case favorite_product?(product.carts_products, product.id) do
      false ->
        {:ok, favorite_product} = Relations.create_favorite_product(%{product_id: product.id, cart_id: cart_id})

        Catalogue.notify_subscribers({:ok, product}, [:product, :updated])
        socket =
          socket
          |> put_flash(:info, "Product added to your favorites")

        {:noreply, socket}
      false ->
        socket =
          socket
          |> put_flash(:error, "Cant add #{product.name} to favorites")
        {:noreply, socket}
    end
  end

  def handle_event("remove_from_favorite",  _, socket) do
    product = socket.assigns.product
    cart_id = socket.assigns.current_cart.id

    [product_id: product.id, cart_id: cart_id]
    |> Relations.get_favorite_product_by!()
    |> Relations.delete_favorite_product()

    Catalogue.notify_subscribers({:ok, product}, [:product, :updated])
    socket = put_flash(socket, :info, "Product removed from your favorites")

    {:noreply, socket}
  end

  def handle_info({Catalogue, [:product, :updated], _}, socket) do
    product = Catalogue.get_product!(socket.assigns.product.id)
    favorite = favorite_product?(product.carts_products, product.id)

    socket =
      socket
      |> assign(:product, product)
      |> assign(:favorite, favorite)

    {:noreply, socket}
  end

  defp favorite_product?(carts, product_id) do
    Enum.any?(carts, &(&1.product_id == product_id))
  end
end
