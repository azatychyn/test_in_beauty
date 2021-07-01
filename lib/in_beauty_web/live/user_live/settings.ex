defmodule InBeautyWeb.UserLive.Profile.Settings do
  # use Phoenix.LiveView
  use InBeautyWeb, :live_view

  # alias InBeautyWeb.UserLive
  alias InBeautyWeb.Router.Helpers, as: Routes
  alias InBeauty.Accounts
  # alias InBeauty.Accounts.User
  alias InBeautyWeb.Forms.UserFormComponent

  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session) #here we put current_user

    socket =
      socket
      |> assign(:email_changeset, Accounts.change_user_email(socket.assigns.current_user))
      |> assign(:password_changeset, Accounts.change_user_password(socket.assigns.current_user))
      |> assign(:user_changeset, Accounts.change_user(socket.assigns.current_user))

    {:ok, socket}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.current_user
      |> InBeauty.Accounts.change_user_registration(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("update_email", params, socket) do
    socket = authenticate(socket)
    %{"user" => %{"current_password" => password} = user_params} = params
    current_user = socket.assigns.current_user

    case Accounts.apply_user_email(current_user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(
          applied_user,
          current_user.email,
          &Routes.user_settings_url(socket, :confirm_email, &1)
        )
        socket =
          put_flash(socket, :info,
            "A link to confirm your email change has been sent to the new address."
          )
        {:noreply, socket}
      {:error, changeset} ->
        {:noreply, assign(socket, :email_changeset, changeset)}
    end
  end

  def handle_event("update_password", params, socket) do
    socket = authenticate(socket)
    %{"user" => %{"current_password" => password} = user_params} = params
    current_user = socket.assigns.current_user

    case Accounts.update_user_password(current_user, password, user_params) do
      {:ok, current_user} ->
        socket =
          socket
          |> put_flash(:info, "Password updated successfully.")
          |> assign(:current_user, current_user)
          |> redirect(to: Routes.user_authorization_path(socket, :create))

        {:noreply, socket}
      {:error, changeset} ->
        {:noreply, assign(socket, :password_changeset, changeset)}
    end
  end

  def handle_event("update_profile", %{"user" => user_params}, socket) do
    socket = authenticate(socket)
    current_user = socket.assigns.current_user

    case Accounts.update_user(current_user, user_params) do
      {:ok, current_user} ->
        socket =
          socket
          |> put_flash(:info, "User updated successfully.")
          |> assign(:current_user, current_user)
          |> assign(:user_changeset, Accounts.change_user(current_user))

        {:noreply, socket}
      {:error, changeset} ->
        {:noreply, assign(socket, :user_changeset, changeset)}
    end
  end
end
