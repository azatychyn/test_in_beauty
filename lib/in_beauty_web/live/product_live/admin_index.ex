defmodule InBeautyWeb.ProductLive.AdminIndex do
  use InBeautyWeb, :live_view

  alias InBeauty.Catalogue
  alias InBeauty.Catalogue.{Product, Stock, Review}
  alias InBeautyWeb.Forms.ProductFormComponent
  alias InBeautyWeb.InputComponent
  alias InBeauty.Repo
  # TODO make filters in local storage

  def render(assigns) do
    if connected?(assigns.socket) do
      InBeautyWeb.ProductView.render("admin_index.html", assigns)
    else
      InBeautyWeb.ProductView.render("admin_index_loading.html", assigns)
    end
  end
  @impl true
  def mount(params, session, socket) do
    page = String.to_integer(params["page"] || "1")
    page_size = String.to_integer(params["page_size"] || "5")
    params = %{"page" => 1, "page_size" => page_size * (page - 1) , "price" => params["price"]}
    products = Catalogue.list_products(params)
    pages =
      products.entries
      |> Enum.chunk_every(page_size)
      |> Enum.with_index(1)
      |> Enum.reduce(%{}, fn {entries, index}, acc ->
        Map.put(acc, :"page_#{index}", entries)
      end)
    volumes_variants = ["30", "40", "50", "100", "200"]
    genders_variants = ["men", "women"]

    socket =
      socket
      |> assign_defaults(session)
      |> assign(:volumes_variants, volumes_variants)
      |> assign(:genders_variants, genders_variants)
      |> assign(:page_title, "Listing Products")
      |> assign(:return_path, :product_admin_index_path)
      |> assign(:max_page, 0)
      |> assign(:loaded_pages, Enum.to_list(1..(page - 1)))

    {:ok, socket, temporary_assigns: [pages: pages]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    filter_options = %{
      page: String.to_integer(params["page"] || "1"),
      page_size: String.to_integer(params["page_size"] || "5"),
      genders: params["genders"] || [],
      volumes: params["volumes"] || [],
      manufacturers: params["manufacturers"] || [],
      price: params["price"] || ["0", "10000"]
    }

    socket =
      socket
      |> assign(:filter_options, filter_options)
      |> apply_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  defp apply_action(socket, :index, params) do
    connected = connected?(socket)
    products = prodcts_by_connection_type(socket, connected)
    max_page = max(socket.assigns.max_page, socket.assigns.filter_options.page)
    pages = Map.put(socket.assigns.pages, :"page_#{products.page_number}", products.entries)

    socket
    |> assign(:total_pages, products.total_pages)
    |> assign(:pages, pages)
    |> assign(:total_pages, products.total_pages)
    |> assign(:max_page, max_page)
    |> update(:loaded_pages, fn loaded_pages -> [products.page_number | loaded_pages] end)
  end

  defp apply_action(socket, :filters, params) do
    products_count = Catalogue.count_products(socket.assigns.filter_options)
    products = %{
      entries: [],
      page_size: socket.assigns.filter_options.page_size,
      page_number: socket.assigns.filter_options.page,
      total_pages: 1
    }

    socket
    |> assign(:products_count, products_count)
    |> assign(:total_pages, products.total_pages)
  end

  def prodcts_by_connection_type(socket, false) do
    page_size = socket.assigns.filter_options.page_size
    products = %{
      entries: Enum.to_list(1..page_size),
      page_size: page_size,
      page_number: socket.assigns.filter_options.page,
      total_pages: 1
    }
  end
  def prodcts_by_connection_type(socket, _) do
    Catalogue.list_products(socket.assigns.filter_options)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    socket = authenticate(socket)
    product = Catalogue.get_product!(id)
    # error -> remount => product will not be deleted
    {:ok, _} = Catalogue.delete_product(product)

    product.stocks
    |> Enum.filter(&(!is_nil(&1.image_path)))
    |> Enum.each(fn %{image_path: "/uploads" <> path} ->
      full_image_path = Path.join(InBeauty.UploadsPath.get_path(), path)
      File.rm(full_image_path)
    end)

    {:noreply,
      push_redirect(socket,
        to: Routes.product_admin_index_path(socket, :index, socket.assigns.filter_options),
        replace: true
      )
    }
  end

  def handle_event("sort", %{"page_size" => page_size}, socket) do
    filter_options = Map.put(socket.assigns.filter_options, :page_size, page_size)
    socket =
      socket
      |> assign(:filter_options, filter_options)
      |> product_path_with_options(:index, filter_options)

    {:noreply, socket}
  end

  defp load_more?(current_page, total_pages) do
    (current_page < total_pages)
  end
end
