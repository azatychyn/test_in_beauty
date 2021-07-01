defmodule InBeautyWeb.UserLive.ResetPassword do
# use InBeautyWeb, :live_view
  use Phoenix.LiveView,
    container: {:div, class: "m-auto flex justify-center items-center dark:text-rose-100 dark:bg-midnight-700"},
    layout: {InBeautyWeb.LayoutView, "mail_live.html"}

  use Phoenix.HTML


  import Phoenix.View
  import InBeautyWeb.Gettext
  import InBeautyWeb.ErrorHelpers
  import Phoenix.LiveView.Helpers
  import InBeautyWeb.LiveHelpers

  alias InBeautyWeb.Router.Helpers, as: Routes
  alias InBeautyWeb.UserLive
  alias InBeauty.Accounts
  alias InBeauty.Accounts.User
  alias InBeautyWeb.UserAuth
  alias InBeautyWeb.Forms.UserFormComponent

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def mount(params, session, socket) do
    socket = assign_defaults(socket, session) #here we put current_user
    changeset = Accounts.change_user_password(socket.assigns.current_user)
    socket = assign(socket, :changeset, changeset)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
      <div class="flex items-center justify-center bg-arrow-down h-full md:px-40 md:py-32 rounded-2xl border-8 border-fuchsia-100 ">
        <div class="flex flex-col items-center bg-rose-100 dark:bg-midnight-500 w-full sm:w-120 rounded-2xl p-6 2xl:p-12 shadow-2xl">
          <h1 class="text-2xl font-extrabold xl:text-3xl">
            <%= gettext "Reset Password" %>
          </h1>
          <div class="flex-1 w-full xs:w-96 lg:w-120 mt-8 sm:px-6 2xl:px-12">
            <%= live_component(
                  @socket,
                  UserFormComponent,
                  fields: [:password, :password_confirmation],
                  required_fields: [:password, :password_confirmation],
                  changeset: @changeset,
                  button_text:  gettext("Update"),
                  live_action: @live_action,
                  handle_events: [phx_change: :validate, phx_submit: :save],
                  id_prefix: "reset_password"
                )
            %>
          </div>
        </div>
      </div>
    """
  end
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.current_user
      |> InBeauty.Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.current_user, user_params) do
      {:ok, _} ->
        socket =
          socket
          |> put_flash(:info, "Password reset successfully.")
          |> redirect(to: "/")

        {:noreply, socket}
      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
