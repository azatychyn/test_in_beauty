defmodule InBeautyWeb.LiveHelpers do

  import Phoenix.LiveView.Helpers
  import Phoenix.LiveView, only: [assign_new: 3, assign: 3, push_patch: 2, get_connect_params: 1]

  alias InBeautyWeb.Router.Helpers, as: Routes
  alias InBeautyWeb.LiveViewAuthorization
  @doc """
  Renders a component inside the `InBeautyWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, InBeautyWeb.UserLive.FormComponent,
        id: @user.id || :new,
        action: @live_action,
        user: @user,
        return_to: Routes.user_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, InBeautyWeb.ModalComponent, modal_opts)
  end

  def map_live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :map_modal, return_to: path, component: component, opts: opts]
    live_component(socket, InBeautyWeb.MapModalComponent, modal_opts)
  end

  def search_live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :search_modal, return_to: path, component: component, opts: opts]
    live_component(socket, InBeautyWeb.SearchModalComponent, modal_opts)
  end

  def parse_phone_number(phone_number) do
    Regex.replace(~r/.(.{3})(.{3})(.{2})(.{2})/, phone_number, "+7 (\\1) \\2-\\3-\\4")
  end

  def get_changeset_field(changeset, field), do: Ecto.Changeset.get_field(changeset, field)
  @doc """
  Put default assigns to socket:
    - current user
    - cart
    - page_title
    - device
  """
  def assign_defaults(socket, session) do
    session_id = session["session_id"]
    token = LiveViewAuthorization.get_user_token(session)
    cart_id = LiveViewAuthorization.get_cart_id(session)

    info = get_connect_params(socket)

    socket
    |> LiveViewAuthorization.put_current_user(token)
    |> LiveViewAuthorization.put_cart(cart_id, session_id)
    |> assign(:user_token, token)
    |> assign(:device, info["device"])
  end

  def authenticate(socket) do
    token = socket.assigns.user_token || ""
    socket.private
    socket
    |> assign(:current_user, InBeauty.Accounts.get_user_by_session_token(token))
    |> LiveViewAuthorization.maybe_load_resource()
  end

  def product_path_with_options(socket, action, filter_options) do
    push_patch(socket,
      to:
        apply(
          Routes,
          socket.assigns.return_path,
          [
            socket,
            action,
            filter_options
          ]
        ),
      replace: true
    )
  end

  def cart_path_with_options(socket, action, filter_options) do
    push_patch(socket,
      to:
        apply(
          Routes,
          socket.assigns.return_path,
          [
            socket,
            action,
            filter_options
          ]
        ),
      replace: true
    )
  end
end
