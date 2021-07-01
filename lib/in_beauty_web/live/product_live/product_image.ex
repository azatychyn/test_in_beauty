defmodule InBeautyWeb.ProductLive.Image do
  use InBeautyWeb, :live_view

  alias InBeauty.Catalogue
  alias InBeauty.Relations
  alias InBeautyWeb.Forms.ProductImageComponent
  # alias InBeauty.Catalogue.{Product, Stock, Review}
  # alias InBeautyWeb.Forms.ProductFormComponent
  # alias InBeautyWeb.InputComponent
  # alias InBeauty.Repo

  def render(assigns) do
    ~L"""
    <div class="absolute inset-0 z-50 w-screen h-screen bg-white ">
      <img class="w-60v lg:w-full h-full lg:max-h-152 rounded-2xl object-contain mx-auto p-16" src="<%= @image_path %>" alt="Nike Air">
    </div>
    """
  end
  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign_defaults(session)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"path" => path}, _url, socket) do

    socket =
      socket
      |> assign(:page_title, "Image - #{path}")
      |> assign(:image_path, path)

    {:noreply, socket}
  end


  def handle_event("add_more",  _, socket) do
    cart_id = socket.assigns.current_cart.id
    product_id = socket.assigns.product.id
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
    # stock_cart_params = Map.put(stock_cart_params, "cart_id", socket.assigns.current_cart.id)
    # IO.inspect(params)
    # case Relations.create_stock_cart(stock_cart_params) do
    #   {:ok, stock_cart} ->
    #       #notify subscribes to update the cart
    #     Payments.notify_subscribers({:ok, socket.assigns.current_cart}, [:cart, :updated])
    #     {:noreply, put_flash(socket, :info, "Product Successfully Added To Cart")}

    #   {:error, %Ecto.Changeset{errors: [cart_id: {"has already been taken", _}]} = changeset} ->
    #     socket =
    #       socket
    #       |> put_flash(:info, "Product has already in the cart")
    #       |> assign(changeset: changeset)
    #     {:noreply, socket}
    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     socket =
    #       socket
    #       |> put_flash(:error, "ERROR: Can't Add Product To Cart, Update The Page")
    #       |> assign(changeset: changeset)
    #     {:noreply, socket}
    # end
  end
end
