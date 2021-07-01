defmodule InBeautyWeb.Plugs.UserByResetPasswordToken do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]

  alias InBeauty.Accounts
  def init(opts), do: opts

  def call(%{params: %{"token" => token} } = conn, _opts) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      conn
      |> assign(:user, user)
      |> assign(:token, token)
      #TODO check if should assign to conn
    else
      conn
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: "/")
      |> halt()
    end
  end
  def call(conn, _) do
    conn
    |> put_flash(:error, "Reset password token is missing.")
    |> redirect(to: "/")
    |> halt()
  end
end
