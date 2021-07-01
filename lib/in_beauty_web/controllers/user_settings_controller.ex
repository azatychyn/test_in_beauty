defmodule InBeautyWeb.UserSettingsController do
  use InBeautyWeb, :controller

  alias InBeauty.Accounts
  # alias InBeautyWeb.UserAuth

  # plug :assign_email_and_password_changesets
#TODO check if plug should be here
  # def update(conn, %{"action" => "update_password"} = params) do
  #   %{"current_password" => password, "user" => user_params} = params
  #   user = conn.assigns.current_user

  #   case Accounts.update_user_password(user, password, user_params) do
  #     {:ok, user} ->
  #       conn
  #       |> put_flash(:info, "Password updated successfully.")
  #       |> put_session(:user_return_to, Routes.user_settings_path(conn, :edit))
  #       |> UserAuth.log_in_user(user)

  #     {:error, changeset} ->
  #       render(conn, "edit.html", password_changeset: changeset)
  #   end
  # end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.user_profile_settings_path(conn, :settings))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.user_profile_settings_path(conn, :settings))
    end
  end

  # defp assign_email_and_password_changesets(conn, _opts) do
  #   user = conn.assigns.current_user

  #   conn
  #   |> assign(:email_changeset, Accounts.change_user_email(user))
  #   |> assign(:password_changeset, Accounts.change_user_password(user))
  # end
end
