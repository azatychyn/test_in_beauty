defmodule InBeautyWeb.UserLive.Authorization do
  # use Phoenix.LiveView
  use InBeautyWeb, :live_view

  alias InBeautyWeb.UserLive
  alias InBeautyWeb.Router.Helpers, as: Routes
  alias InBeauty.Accounts
  alias InBeauty.Accounts.User
  alias InBeautyWeb.UserAuth
  alias InBeautyWeb.Forms.UserFormComponent

  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)
    changeset = Accounts.change_user_registration(%User{})
    socket =
      socket
      |> assign_defaults(session)
      |> assign(:changeset, changeset)
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> InBeauty.Accounts.change_user_registration(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("sign_up", %{"user" => user_params}, socket) do
    socket = authenticate(socket)
    user_params = put_in(user_params, ["role"], :user)

    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(socket, :confirm, &1)
          )
        socket =
          socket
          |> put_flash(:info, "User created successfully.")
          |> push_redirect(to: "/") #TODO change route to sign in path

        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("sign_in", %{"user" => user_params}, socket) do
    socket = authenticate(socket)
    %{"email" => email, "password" => password} = user_params
    changeset =
      Accounts.change_user_registration(
        %{socket.assigns.changeset.data | password: password, email: email}
      )

    case Accounts.get_user_by_email_and_password(email, password) do
      nil ->
        socket = assign(socket, :changeset, changeset)
        {:noreply, put_flash(socket, :error, "Invalid email or password")}
      _user ->
        socket =
          socket
          |> assign(:trigger_submit, true)
          |> assign(:changeset, changeset)

        {:noreply, socket}

    end
  end

  def handle_event("password_recovery", %{"user" => %{"email" => email}} , socket) do
    socket = authenticate(socket)
    with  %User{} = user <- Accounts.get_user_by_email(email),
          Accounts.deliver_user_reset_password_instructions(
            user,
            &Routes.user_reset_password_url(socket, :reset_password, &1)
          )
    do
      socket =
        socket
        |> put_flash(:info, "If your email is in our system, you will receive instructions to reset your password shortly.")
        #TODO redirect to what?
        |> redirect(to: "/")

      {:noreply, socket}
    else
      {:permanent_failure, _msg} ->
        {:noreply, put_flash(socket, :error, "Try in 5 minutes")}
      nil ->
        {:noreply, put_flash(socket, :error, "Can't Recognize Email")}
      _ ->
        {:noreply, put_flash(socket, :error, "Unsupported error")}
    end
  end
end
