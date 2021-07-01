defmodule InBeautyWeb.CartLive.Index do
  use InBeautyWeb, :live_view

  alias InBeauty.Payments
  alias InBeauty.Payments.Cart
  alias InBeautyWeb.Forms.CartFormComponent
  alias InBeautyWeb.InputComponent
  alias InBeauty.Repo
  # todo make filters in local storage

  # def render(assigns) do
  #   if connected?(assigns.socket) do
  #     InBeautyWeb.CartView.render("index.html", assigns)
  #   else
  #     InBeautyWeb.CartView.render("index_loading.html", assigns)
  #   end
  # end
  @impl true
  def mount(params, session, socket) do
    page = String.to_integer(params["page"] || "1")
    page_size = String.to_integer(params["page_size"] || "5")
    params = %{"page" => 1, "page_size" => page_size * (page - 1) , "price" => params["price"]}
    carts = Payments.list_carts(params)
    pages =
      carts.entries
      |> Enum.chunk_every(page_size)
      |> Enum.with_index(1)
      |> Enum.reduce(%{}, fn {entries, index}, acc ->
        Map.put(acc, :"page_#{index}", entries)
      end)

    roles_variants = ["user", "anon"]

    socket =
      socket
      |> assign_defaults(session)
      |> assign(:page_title, "Listing Carts")
      |> assign(:return_path, :cart_index_path)
      |> assign(:roles_variants, roles_variants)
      |> assign(:max_page, 0)
      |> assign(:loaded_pages, Enum.to_list(1..(page - 1)))

    {:ok, socket, temporary_assigns: [pages: pages]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    filter_options = %{
      page: String.to_integer(params["page"] || "1"),
      page_size: String.to_integer(params["page_size"] || "5"),
      roles: params["roles"] || []
    }

    socket =
      socket
      |> assign(:filter_options, filter_options)
      |> apply_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  defp apply_action(socket, :index, params) do
    connected = connected?(socket)
    carts = prodcts_by_connection_type(socket, connected)
    max_page = max(socket.assigns.max_page, socket.assigns.filter_options.page)
    pages = Map.put(socket.assigns.pages, :"page_#{carts.page_number}", carts.entries)

    socket
    |> assign(:total_pages, carts.total_pages)
    |> assign(:pages, pages)
    |> assign(:max_page, max_page)
    |> update(:loaded_pages, fn loaded_pages -> [carts.page_number | loaded_pages] end)
  end
  defp apply_action(socket, :filters, params) do
    carts_count = Payments.count_carts(socket.assigns.filter_options)
    carts = %{
      entries: [],
      page_size: socket.assigns.filter_options.page_size,
      page_number: socket.assigns.filter_options.page,
      total_pages: 1
    }

    socket
    |> assign(:carts_count, carts_count)
    |> assign(:total_pages, carts.total_pages)
  end

  def prodcts_by_connection_type(socket, false) do
    page_size = socket.assigns.filter_options.page_size
    carts = %{
      entries: Enum.to_list(1..page_size),
      page_size: page_size,
      page_number: socket.assigns.filter_options.page,
      total_pages: 1
    }
  end
  def prodcts_by_connection_type(socket, _) do
    Payments.list_carts(socket.assigns.filter_options)
  end

  def handle_event("sort", params, socket) do
    page_size = params["page_size"] || socket.assigns.filter_options.page_size
    roles = params["roles"] || socket.assigns.filter_options.roles
    filter_options =
      socket.assigns.filter_options
      |> Map.put(:page_size, page_size)
      |> Map.put(:roles, roles)

    socket =
      socket
      |> assign(:filter_options, filter_options)
      |> push_redirect(to: Routes.cart_index_path(socket, :index, filter_options))

    {:noreply, socket}
  end

  defp load_more?(current_page, total_pages) do
    (current_page < total_pages)
  end
end
