defmodule InBeautyWeb.ProductLive.AdminNew do
  use InBeautyWeb, :live_view

  alias InBeauty.Catalogue
  alias InBeauty.Catalogue.{Product, Stock, Review}
  alias InBeautyWeb.Forms.ProductFormComponent
  alias InBeautyWeb.InputComponent
  alias InBeauty.Repo

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign_defaults(session)
      |> assign(:uploaded_files, [])
      |> assign(:required_fields, [:description, :gender, :name, :manufacturer])
      |> assign(:fields, [:description, :gender, :name, :manufacturer])
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    changeset =
      %Product{}
      |> Catalogue.change_product()
      |> Map.put(:action, :insert)

    socket =
      socket
      |> assign(:page_title, "New Product")
      |> assign(:changeset, changeset)

    {:noreply, socket}
  end

  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> Catalogue.change_product(product_params)
      |> Map.put(:action, :insert)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    socket = authenticate(socket)
    new_product_params = put_images_paths(socket, product_params)

    case Catalogue.create_product(new_product_params, &consume_stock_iamges(socket, &1)) do
      {:ok, _product} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "product created")
          |> push_redirect(to: Routes.product_admin_index_path(socket, :index))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("add_stock", _, socket) do
    existing_stocks = Map.get(socket.assigns.changeset.changes, :stocks, socket.assigns.changeset.data.stocks)
    id = Ecto.UUID.generate()
    stocks =
      existing_stocks
      |> Enum.concat([
        Catalogue.change_stock(%Stock{}, %{id: id})
      ])

    changeset = Ecto.Changeset.put_assoc(socket.assigns.changeset, :stocks, stocks)

      socket =
        socket
        |> assign(:changeset, changeset)
        |> allow_upload(:"image_#{id}", accept: ~w(.jpg .jpeg .png), auto_upload: true)
    {:noreply, socket}
  end

  def handle_event("remove_stock", %{"id" => id}, socket) do
    socket_without_image_entries =
      Enum.reduce(socket.assigns.uploads[:"image_#{id}"].entries, socket, fn entry, acc ->
        cancel_upload(acc, :"image_#{id}", entry.ref)
      end)

    stocks = Enum.reject(socket.assigns.changeset.changes.stocks, &(&1.changes.id == id))

    changeset = Ecto.Changeset.put_assoc(socket.assigns.changeset, :stocks, stocks)

    socket =
      socket_without_image_entries
      |> disallow_upload(:"image_#{id}")
      |> assign(:changeset, changeset)
    {:noreply, socket}
  end

  def handle_event("cancel-entry", %{"ref" => ref, "id" => id}, socket) do
    {:noreply,  cancel_upload(socket, :"image_#{id}", ref)}
  end


  def put_images_paths(socket, %{"stocks" =>  _} = params) do
    Enum.reduce(params["stocks"], params, fn {index, stock_params}, acc ->
      case get_image_paths(socket, stock_params["id"]) do
        [url] ->
          put_in(acc, [
            Access.key("stocks"),
            Access.key(index),
            Access.key("image_path")
          ], url)
        [] ->
          acc
      end
    end)
  end
  def put_images_paths(_socket, params), do: params

  defp get_image_paths(socket, id) do
    # if uploaded_entries return {[], [#Phoenix.LiveView.UploadConfig<>]}
    # it will raise an error that will garantee that returns all uploads will be complited
     case uploaded_entries(socket, :"image_#{id}") do
      {complited, []} ->
        for entry <- complited do
          Routes.static_path(socket, "/uploads/#{entry.uuid}.#{ext(entry)}")
        end
      {[], []} ->
        []
    end
  end

  defp ext(entry) do
    entry.client_type
    |> MIME.extensions()
    |> hd()
  end

  defp consume_stock_iamges(socket, product) do
    Enum.each(product.stocks, fn stock ->
      case uploaded_entries(socket, :"image_#{stock.id}") do
        {_complited, []} ->
          consume_image(socket, stock.id)
        {[], []} ->
      nil
      end
    end)
    {:ok, product}
  end


  defp consume_image(socket, id) do
    consume_uploaded_entries(socket, :"image_#{id}", fn meta, entry ->
      destination_path = Path.join(InBeauty.UploadsPath.get_path(), "#{entry.uuid}.#{ext(entry)}")
      destination_path |> Path.dirname |> File.mkdir_p
      File.cp!(meta.path, destination_path)
    end)
  end
  def required?(field, required_fields) do
    if (field in required_fields), do: true, else: false
  end

  defp list_products do
    Catalogue.list_products()
  end
end
