defmodule InBeautyWeb.LiveViewAuthorization do

  import Phoenix.LiveView
  import InBeauty.Authorization

  alias InBeautyWeb.Router.Helpers, as: Routes
  alias InBeauty.Accounts.User
  alias InBeauty.Payments.Cart
  alias InBeauty.Payments


  def put_current_user(socket, nil) do
    assign(socket, :current_user, nil)
  end
  def put_current_user(socket, token) do
    assign_new(socket, :current_user, fn -> InBeauty.Accounts.get_user_by_session_token(token) end)
  end

  #TODO if cart deleted redirect to a route that delete cart from session and redirect back or some other logic to think I SHOULD DELETE CART TO TEST IT
  def put_cart(socket, nil, _session_id) do
    assign(socket, :current_cart, nil)
  end
  def put_cart(socket, cart_id, session_id) do
    session_cache = ConCache.get(:session_data, session_id)
    cached_cart = session_cache[:cart]

    if cached_cart && cached_cart.id == cart_id do
      assign(socket, :current_cart, cached_cart)
    else
      cart = InBeauty.Payments.get_cart!(cart_id)
      ConCache.update(:session_data, session_id, fn value ->
        {:ok, Map.put(value || %{}, :cart, cart)}
      end)
      assign(socket, :current_cart, cart)
    end
  end

  def get_user_token(%{"user_token" => user_token}), do: user_token
  def get_user_token(_), do: nil

  def get_cart_id(%{"current_cart_id" => cart_id}), do: cart_id
  def get_cart_id(_), do: nil

  def maybe_load_resource(socket) do
    live_action = socket.assigns.live_action
    role = socket.assigns["current_user"]["role"] || "anon"
    resource = get_resource(socket.view)

    check(live_action, role, resource)
    |> maybe_continue(socket)
  end

  defp maybe_continue(true, socket), do: socket
  defp maybe_continue(false, socket) do
    socket
    |> put_flash(:error, "You're not authorized to do that!")
    |> push_redirect(to: "/") #TODO send where?
  end

  defp check(:index, role, resource) do
    can(role) |> index?(resource)
  end

  defp check(:checkout, role, resource) do
    can(role) |> checkout?(resource)
  end

  defp check(:sign_in, role, resource) do
    can(role) |> sign_in?(resource)
  end

  defp check(:sign_up, role, resource) do
    can(role) |> sign_up?(resource)
  end

  defp check(:sign_out, role, resource) do
    can(role) |> sign_out?(resource)
  end

  defp check(:reset_password, role, resource) do
    can(role) |> reset_password?(resource)
  end
  #TODO check if live veiw need this routs
  defp check(action, role, resource) when action in [:new, :create] do
    can(role) |> create?(resource)
  end

  defp check(action, role, resource) when action in [:edit, :update] do
    can(role) |> update?(resource)
  end

  defp check(:delete, role, resource) do
    can(role) |> delete?(resource)
  end

  defp check(_action, _role, _resource), do: false
end
