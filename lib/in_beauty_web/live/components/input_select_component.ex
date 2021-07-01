defmodule InBeautyWeb.InputSelectComponent do
  use InBeautyWeb, :live_component

  @defaults %{
    wrapper_size: ""
  }

  @impl Phoenix.LiveComponent
  def mount(socket) do
    socket =
      socket
      |> assign(@defaults)
    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do

    if assigns.device == "mobile" do
      InBeautyWeb.SelectView.render("select_mobile.html", assigns)
    else
      InBeautyWeb.SelectView.render("input_select.html", assigns)
    end
  end
end
