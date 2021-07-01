defmodule InBeautyWeb.Plugs.SessionPlug do
  import Plug.Conn

  alias InBeauty.Payments
  alias InBeauty.Repo

  def init(_opts), do: nil
  # if we can't creaet cart the code with crash and make reload the will create new cart or will pass again and agains
  def call(%{private: %{:plug_session => %{"session_id" => session_id}}} = conn, _opts) when not is_nil(session_id) do
    conn
  end
  def call(conn, _opts) do
    put_session(conn, "session_id", Ecto.UUID.generate())
  end
end
