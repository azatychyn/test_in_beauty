defmodule InBeautyWeb.Plugs.CurrentCartIdPlug do
  import Plug.Conn

  alias InBeauty.Payments
  alias InBeauty.Payments.Cart
  alias InBeauty.Repo

  def init(_opts), do: nil
  # if we can't creaet cart the code with crash and make reload the will create new cart or will pass again and agains
  def call(%{private: %{:plug_session => %{"current_cart_id" => cart_id}}} = conn, _opts) do
    conn
  end
  def call(%{private: %{:plug_session => %{"session_id" => session_id}}} = conn, _opts) do
    case Payments.get_cart_by([session_id: session_id]) do
      nil ->
        {:ok, cart} = Payments.create_cart(%{anon: true, session_id: session_id})

        ConCache.update(:session_data, session_id, fn value ->
          {:ok, Map.put(value || %{}, :cart, cart)}
        end)

        conn
        |> put_session(:current_cart_id, cart.id)
        |> assign(:current_cart, cart)
      %Cart{} = cart ->
        conn
        |> put_session(:current_cart_id, cart.id)
        |> assign(:current_cart, cart)

    end
  end
  def call(conn, _opts) do
    get_session(conn)
    #TODO redirect ot fallback controller where whould be a link or something to connect of feedback
    conn
  end
end
