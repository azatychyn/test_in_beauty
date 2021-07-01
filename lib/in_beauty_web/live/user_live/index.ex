defmodule InBeautyWeb.UserLive.Index do
  use InBeautyWeb, :live_view

  alias InBeauty.Accounts
  alias InBeauty.Accounts.User
  alias InBeautyWeb.Forms.UserFormComponent

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign_defaults(session)
      |> assign(:users, list_users())
      |> assign(:roles, [])

    {:ok, socket, temporary_assigns: [users: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :update, %{"id" => id}) do
    user = Accounts.get_user!(id)

    socket
    |> assign(:page_title, "Edit User")
    |> assign(:changeset, Accounts.change_user(user))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, assign(socket, :users, list_users())}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_user(socket.assigns.changeset.data, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_redirect(to: Routes.user_index_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("filter", %{ "roles" => roles}, socket) do
    params = [roles: Enum.uniq(roles)]
    users = list_users(params)
    socket = assign(socket, params ++ [users: users])
    {:noreply, socket}
  end

  defp list_users do
    Accounts.list_users()
  end
  defp list_users(criteria) do
    Accounts.list_users(criteria)
  end

  defp role_options do
    [
      "All Types": "",
      Admin: "admin",
      User: "user",
      Anon: "anon"
    ]
  end
end
