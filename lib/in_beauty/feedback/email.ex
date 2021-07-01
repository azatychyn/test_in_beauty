defmodule InBeauty.FeedBack.Email do
  @moduledoc """
      Module that provides sending recovery links to emails
  """

  use Bamboo.Phoenix, view: InBeautyWeb.EmailView

  import Bamboo.Email

  def base_email(email \\ "dgs0196@yandex.ru") do
    new_email()
    |> from("dgs0196@yandex.ru")
    |> to(email)
    |> put_html_layout({InBeautyWeb.LayoutView, "email.html"})
  end


  def fail_order_response(order) do
    base_email(order.email)
    |> subject("Invalid Order")
    |> assign(:order, order)
    |> render("fail_order_response.html")
    |> InBeauty.FeedBack.Mailer.deliver_now() # Send your email
  end

  def order_response(order) do
    base_email(order.email)
    |> subject("Order")
    |> assign(:order, order)
    |> render("order_response.html")
    |> InBeauty.FeedBack.Mailer.deliver_then() # Send your email
  end

  def password_recovery_email(recovery_url, user) do
    # recovery_link =
    #   :in_beauty |> Application.get_env(:env) |> get_path(token)

    new_email()
    |> from("dgs0196@yandex.ru")
    |> to(user.email)
    |> subject("Password Recovery")
    # |> assign(:recovery_url, recovery_url)
    # |> render("password_recovery_response.html")
    |> html_body("<a href=#{recovery_url}>RECOVERY LINK</a>")
    |> InBeauty.FeedBack.Mailer.deliver_now() # Send your email
  end

  def update_email(update_email_url, user) do
    new_email()
    |> from("dgs0196@yandex.ru")
    |> to(user.email)
    |> subject("Update Email")
    |> html_body("<a href=#{update_email_url}>Update Email Link</a>")
    |> InBeauty.FeedBack.Mailer.deliver_now() # Send your email
  end

  # defp get_path(:prod, token) do
  #   add_header("https://InBeauty.com/change_password", token)
  # end
  # defp get_path(_, token) do
  #   add_header("http://localhost:4000/change_password", token)
  # end

  # defp add_header(url, token), do: "#{url}?token=#{token}"
end
