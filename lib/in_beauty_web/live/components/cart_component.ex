defmodule InBeautyWeb.CartComponent do
  use InBeautyWeb, :live_component

  alias InBeauty.Repo
  alias InBeauty.Catalogue
  alias InBeauty.Relations
  alias InBeauty.Relations.StockCart
  alias InBeauty.Payments
  alias InBeautyWeb.Forms.ProductImageComponent

  #TODO make cart component like filters now its separate page
  @impl Phoenix.LiveComponent
  def update(assigns, socket) do

    id = assigns.current_cart.id
    if connected?(socket), do: Payments.subscribe(id)

    cart =
      id
      |> Payments.get_cart!()
      |> Repo.preload([stocks_carts: [stock: [:product]]])
      |> Payments.add_cart_attrs()

    socket =
      socket
      |> assign(:page_title, "Cart")
      |> assign(:cart, cart)

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~L"""
      <div x-show="openCart"
        class="flex justify-center my-6"
      >
        <div class="flex flex-col w-full p-4 sm:p-8 text-gray-800 bg-white shadow-lg pin-r pin-y md:w-4/5 lg:w-4/5">
          <div class="flex-1">
            <table class="w-full text-sm lg:text-base" cellspacing="0">
              <thead>
                <tr class="h-12 sm:uppercase">
                  <th class="hidden md:table-cell"></th>
                  <th class="text-left">Product</th>
                  <th class="lg:text-center  lg:pl-0">
                    <span class="block lg:hidden" title="Quantity">Qtd</span>
                    <span class="hidden lg:inline">Quantity</span>
                  </th>
                  <th class="hidden text-right md:table-cell">Lbs </th>
                  <th class="text-right md:table-cell">Price</th>
                  <th class="text-right md:table-cell"></th>
                </tr>
              </thead>
              <tbody>

              <%= if @cart.stocks_carts == [] do %>
                <div class="h-44">Your cart in empty</div>
              <% else %>
                <%= for {stock_cart, i} <- Enum.with_index(@cart.stocks_carts) do %>
                  <tr>
                    <td class="hidden pb-4 md:table-cell">
                      <a href="#">
                        <img src="<%= stock_cart.stock.image_path %>" class="w-20 rounded" alt="prod_img">
                      </a>
                    </td>
                    <td>
                      <a href="#">
                        <p class="mb-2 md:ml-4"><%= stock_cart.stock.product.name %></p>
                      </a>
                    </td>

                      <td class="justify-center md:flex mt-6">
                        <div class="flex items-center ">

                          <!-- form for decrement stocks_carts count in cart -->

                          <%= f = form_for %Plug.Conn{}, "#", [phx_submit: :dec, as: :stock_cart]  %>
                            <%= hidden_input(f, :stock_cart, value: stock_cart.id) %>
                            <%= hidden_input(f, :quantity, value: stock_cart.quantity ) %>
                            <%= hidden_input(f, :volume, value: stock_cart.volume ) %>
                            <button class="text-gray-500 focus:outline-none focus:text-gray-600">
                              <svg class="h-5 w-5 sm:h-10 sm:w-10 stroke-current text-green-600" fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="1" viewBox="0 0 24 24" stroke="currentColor"><path d="M15 12H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                            </button>
                          </form>

                          <!-- form for decrement stocks_carts count in cart -->

                          <span class="text-gray-700 text-sm sm:text-lg mx-4"> <%= stock_cart.quantity %> </span>

                          <!-- form for increment stocks_carts count in cart -->

                          <%= f = form_for %Plug.Conn{}, "#", [phx_submit: :inc, as: :stock_cart]  %>
                            <%= hidden_input(f, :stock_cart, value: stock_cart.id) %>
                            <%= hidden_input(f, :quantity, value: stock_cart.quantity ) %>
                            <%= hidden_input(f, :volume, value: stock_cart.volume ) %>
                            <button class="text-gray-500 focus:outline-none focus:text-gray-600">
                              <svg class="h-5 w-5 sm:h-10 sm:w-10 stroke-current text-green-600" fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="1" viewBox="0 0 24 24" stroke="currentColor"><path d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                            </button>
                          </form>

                          <!-- form for increment stocks_carts count in cart -->

                        </div>
                      </td>

                    <td class="hidden text-right md:table-cell">
                      <label class="inline-flex items-center mt-3 ml-3">
                        <span class="ml-2 text-gray-700 "><%= stock_cart.stock.volume %></span>
                      </label>
                    </td>
                    <td class="text-right">
                      <span class="text-sm lg:text-base font-medium">
                        $<%= stock_cart.stock.price %>
                      </span>
                    </td>
                    <td class="text-right">
                      <span class="text-sm lg:text-base font-medium">
                          <button
                            type="button"
                            class="text-gray-700 md:ml-4 bg-red-200 px-2 py-1 rounded-md"
                            phx-click="remove_from_cart"
                            phx-value-stock_cart_id="<%= stock_cart.id%>"
                            phx-value-cart_id="<%=@cart.id %>"
                            phx-value-volume="<%= stock_cart.stock.volume %>"
                          >
                          del
                          </button>
                      </span>
                    </td>
                  </tr>
                <% end %>
              <% end %>

              </tbody>
            </table>
            <hr class="pb-6 mt-6">
            <div class="my-4  lg:flex">
              <div class="lg:px-2 lg:w-1/2">
              </div>
              <div class="lg:px-2 lg:w-1/2">
                <div class="p-4 bg-lime-600 text-gray-50 rounded-full">
                  <h1 class="ml-2 font-bold uppercase">Order Details</h1>
                </div>
                <div class="p-4">
                  <p class="mb-6 italic">Additionnal costs is calculated based on values you have entered</p>
                    <div class="flex justify-between border-b">
                      <div class="lg:px-4 lg:py-2 m-2 lg:text-lg font-bold text-center text-gray-900">

                      </div>
                    </div>
                    <div class="flex justify-between pt-4 border-b">
                      <div class="lg:px-4 lg:py-2 m-2 text-lg lg:text-xl font-bold text-center text-gray-800">
                        Total
                      </div>
                      <div class="lg:px-4 lg:py-2 m-2 lg:text-lg font-bold text-center text-gray-900">
                        $<%= @cart.total_price %>
                      </div>
                    </div>
                    <%= live_redirect(
                          to: "Routes.order_new_path(@socket, :new)",
                          class: "flex justify-center w-full px-10 py-3 mt-6 font-medium text-gray-50 uppercase bg-lime-600 rounded-full shadow item-center hover:bg-gray-700 focus:shadow-outline focus:outline-none h-14"
                        ) do %>
                          <svg aria-hidden="true" data-prefix="far" data-icon="credit-card" class="w-8" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 576 512"><path fill="currentColor" d="M527.9 32H48.1C21.5 32 0 53.5 0 80v352c0 26.5 21.5 48 48.1 48h479.8c26.6 0 48.1-21.5 48.1-48V80c0-26.5-21.5-48-48.1-48zM54.1 80h467.8c3.3 0 6 2.7 6 6v42H48.1V86c0-3.3 2.7-6 6-6zm467.8 352H54.1c-3.3 0-6-2.7-6-6V256h479.8v170c0 3.3-2.7 6-6 6zM192 332v40c0 6.6-5.4 12-12 12h-72c-6.6 0-12-5.4-12-12v-40c0-6.6 5.4-12 12-12h72c6.6 0 12 5.4 12 12zm192 0v40c0 6.6-5.4 12-12 12H236c-6.6 0-12-5.4-12-12v-40c0-6.6 5.4-12 12-12h136c6.6 0 12 5.4 12 12z"/></svg>
                          <span class="ml-2  mt-5px">Procceed to checkout</span>
                    <% end %>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    """
  end

  def handle_event("inc", %{"stock_cart" => stock_cart_params}, socket) do
    stock_cart_params
    |> Map.put("cart_id", socket.assigns.current_cart.id)
    |> Enum.map(fn {k, v} -> {:"#{k}", v} end)
    |> update_stock(1)
    |> respond_type(socket)
  end

  def handle_event("dec", %{"stock_cart" => stock_cart_params}, socket) do
    stock_cart_params
    |> Map.put("cart_id", socket.assigns.current_cart.id)
    |> Enum.map(fn {k, v} -> {:"#{k}", v} end)
    |> update_stock(-1)
    |> respond_type(socket)
  end


  def handle_event("remove_from_cart", params, socket) do
    stock_cart =
      params
      |> Enum.map(fn {k, v} -> {:"#{k}", v} end)
      |> Keyword.take([:product_id, :cart_id, :lbs])
      |> Relations.get_stock_cart_by()

    case Relations.delete_stock_cart(stock_cart) do
      {:ok, _} ->
        #notify subscribes to update the cart
        Payments.notify_subscribers({:ok, socket.assigns.cart}, [:cart, :updated])

        {:noreply, put_flash(socket, :info, "Product was successfully deleted from cart")}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Error, can't delete product from cart, try again")}
    end
    {:noreply, socket}
  end

  defp update_stock(stock_cart_params, inc_value) do
    with %StockCart{} = stock_cart <- Relations.get_stock_cart_by(stock_cart_params),
         true <- (stock_cart.quantity + inc_value) > 0,
         {:ok, stock_cart_updated} <- Relations.update_stock_cart(stock_cart, %{quantity: stock_cart.quantity + inc_value})
    do
      cart =
        stock_cart_updated.cart_id
        |> Payments.get_cart!()
        |> InBeauty.Repo.preload([:products])


      cart_with_total_price_and_number = Payments.add_cart_attrs(cart.products, cart)
      {:ok, cart_with_total_price_and_number}
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

  defp respond_type({:ok, cart}, socket) do
    {:noreply, assign(socket, :cart, cart)}
  end
  defp respond_type({:error, :delteted_stock_cart_error}, socket) do
    socket =
      socket
      |> put_flash(:error, "Error, Product was deleted from cart, try again")
      |> push_redirect(to: Routes.cart_show_path(socket, :show, socket.assigns.cart))

    {:noreply, socket}
  end
  defp respond_type({:error, :zero_down_quantity_error}, socket) do
    {:noreply, socket}
  end
  defp respond_type({:error, _}, socket) do
    socket =
      socket
      |> put_flash(:error, "Error, can't update the cart, try again")
      |> push_redirect(to: Routes.cart_show_path(socket, :show, socket.assigns.cart.id))

    {:noreply, socket}
  end

  def handle_event("add_to_cart",  _, socket) do
    cart_id = socket.assigns.current_cart.id
    product_id = socket.assigns.product.id
    # this will reise error if stock not in database
    stock = Catalogue.get_stock!(socket.assigns.selected_stock.id)

    stock_cart_params = %{
      cart_id: cart_id,
      product_id: product_id,
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
  end
end
