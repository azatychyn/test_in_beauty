defmodule InBeautyWeb.CartLive.AddToCartFormComponent do
  use InBeautyWeb, :live_component

  alias InBeauty.Payments
  #TODO add this to all buttons on forms disabled: !@changeset.valid?,
  def mount(socket) do
    socket =
      socket
      |> assign(:quantity, 1)
      |> assign(:lbs_checked, :"25")
    {:ok, socket}
  end
  def render(assigns)do
    ~L"""
      <div class="w-full max-w-lg mx-auto mt-5 md:ml-8 md:mt-0 md:w-1/2">
        <%= f = form_for %Plug.Conn{}, @form_action, @handle_events ++ [class: "grid grid-flow-row grid-cols-1 grid-rows-7 gap-2", as: :stock_cart]  %>
            <%= hidden_input(f, :product_id, value: @product.id) %>
            <%= hidden_input(f, :quantity, value: @quantity) %>
            <h3 class="text-gray-700 uppercase text-lg"><%= @product.name %></h3>
            <span class="text-gray-500 mt-3"><%= @product.description %></span>
            <span class="text-gray-500 mt-3">$<%= @product.price %></span>
            <hr class="my-3">
            <div class="mt-2">
                <label class="text-gray-700 text-xl mb-8" for="count">Count:</label>
                <div class="flex items-center my-6">
                    <button
                      type="button"
                      class="text-gray-500 focus:outline-none focus:text-gray-600"
                      phx-click="dec"
                      phx-target="<%= @myself %>"
                      <%= if @quantity <= 1, do: "disabled" %>
                    >
                      <svg class="h-10 w-10 stroke-current text-green-600" fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="1" viewBox="0 0 24 24" stroke="currentColor"><path d="M15 12H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    </button>
                    <span class="text-gray-700 text-lg mx-4"> <%= @quantity %> </span>
                    <button
                      type="button"
                      class="text-gray-500 focus:outline-none focus:text-gray-600"
                      phx-click="inc"
                      phx-target="<%= @myself %>"
                    >
                      <svg class="h-10 w-10 stroke-current text-green-600" fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="1" viewBox="0 0 24 24" stroke="currentColor"><path d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    </button>
                </div>
            </div>
            <div class="">
                <label class="text-gray-700 text-xl" for="count">Lbs:</label>
                <div class="flex items-center mt-1">

                  <!-- stock lbs for add_to_cart form-->

                  <%= for {lbs, inStock?} <- Map.from_struct(@product.stock) do %>
                    <label class="inline-flex items-center mt-3 ml-3">
                      <input
                        id="lbs_<%= lbs %>"
                        name="stock_cart[lbs]"
                        type="radio"
                        value="<%= lbs %>"
                        phx-click="change_lbs"

                        phx-target="<%= @myself %>"
                        class="form-radio h-7 w-7 text-green-600 <%= if !inStock?, do: 'opacity-50' %>"
                        required
                        <%= if @lbs_checked  == lbs, do: "checked" %>
                        <%= if !inStock?, do: "disabled" %>
                      >
                      <span class="ml-2 text-gray-700 <%= if !inStock?, do: 'opacity-50' %> "><%= lbs %></span>
                    </label>
                  <% end %>

                  <!-- stock lbs for add_to_cart form-->

                </div>
            </div>

            <div class="col-span-1 w-60 mt-6" phx-target="<%= @myself %>">
              <%= submit  phx_disable_with: "Saving...", class: "flex justify-around items-center w-full border border-green-500 text-lg text-green-500 rounded-md px-12 py-4 transition duration-500 ease select-none hover:text-gray-50 hover:bg-green-600 focus:outline-none focus:outline-none" do %>
              <svg class="h-5 w-5" fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24" stroke="currentColor"><path d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"></path></svg>
              Add To Cart<% end %>
            </div>
        </form>
      </div>
    """
  end

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :quantity, &(&1 + 1))}
  end

  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :quantity, &(&1 - 1))}
  end

  def handle_event("change_lbs",  %{"value" => lbs}, socket) do
    {:noreply, assign(socket, :lbs_checked, :"#{lbs}")}
  end
end
