defmodule InBeautyWeb.UserLive.Profile do
  use InBeautyWeb, :live_view

  alias InBeautyWeb.Router.Helpers, as: Routes
  alias InBeauty.Accounts
  # alias InBeautyWeb.UserLive
  # alias InBeauty.Accounts.User
  def mount(_params, session, socket) do
    {:ok, assign_defaults(socket, session)}
  end
end
