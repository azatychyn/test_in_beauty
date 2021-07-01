defmodule InBeautyWeb.UserSignUpTest do
  use InBeautyWeb.ConnCase, async: true

  import InBeauty.AccountsFixtures
  import Phoenix.LiveViewTest

  describe "Anon live registration" do
    setup %{conn: conn} do
      conn =
        conn
        |> Map.replace!(:secret_key_base, InBeautyWeb.Endpoint.config(:secret_key_base))
        |> init_test_session(%{})

      %{user: user_fixture(), conn: conn}
    end

    test "renders registration page", %{conn: conn} do
      {:ok, view, disconnected_html} = live(conn, Routes.user_authorization_path(conn, :create))
      assert view.module == InBeautyWeb.UserLive.SignUp
    end

    test "success: create user and redirects to main page", %{conn: conn} do
      {:ok, view, disconnected_html} = live(conn, Routes.user_authorization_path(conn, :create))
      email = unique_user_email()
      assert {:error, {:live_redirect, %{to: "/", flash: flash}}} =
        view
        |> element("form")
        |> render_submit(
          %{
            "user" => %{
              "email" => email,
              "password" => valid_user_password(),
              "role" => "user",
              "first_name" => "david",
              "phone_number" => "79996990099"
            }
          }
         )

      assert Phoenix.LiveView.Utils.verify_flash(InBeautyWeb.Endpoint, flash)["info"] ==  assert_redirect(view, "/")["info"]
    end

    test "fail: create user and put changeset", %{conn: conn} do
      {:ok, view, disconnected_html} = live(conn, Routes.user_authorization_path(conn, :create))
      email = unique_user_email()
      response =
        view
      |> element("form")
      |> render_submit(
        %{
          "user" => %{
            "email" => email,
            "password" => invalid_user_password(),
            "role" => "user",
            "first_name" => "david",
            "phone_number" => "79996990099"
          }
        }
        )
      assert  String.contains?(response, "Create Account\n")
    end
  end

  describe "Auth live registration" do
    setup :register_and_log_in_user

    test "redirects if already logged in", %{conn: conn, user: user} do
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, Routes.user_authorization_path(conn, :create))
    end
    #TODO maybe to do the second level of quard to make functions to check if user exists or return error some way by constraint

    # test "render errors for invalid data", %{conn: conn} do
    #   conn =
    #     post(conn, Routes.user_authorization_path(conn, :create), %{
    #       "user" => %{"email" => "with spaces", "password" => "too short"}
    #     })

    #   response = html_response(conn, 200)
    #   assert response =~ "<h1>Register</h1>"
    #   assert response =~ "must have the @ sign and no spaces"
    #   assert response =~ "should be at least 12 character"
    # end
  end
end
