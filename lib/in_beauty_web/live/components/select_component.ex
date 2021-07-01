defmodule InBeautyWeb.SelectComponent do
  use InBeautyWeb, :live_component

  @defaults %{
    variants: [],
    selected_variant: nil,
    placeholder: "",
    wrapper_size: ""
  }

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, @defaults)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do

    if assigns.device == "mobile" do
      InBeautyWeb.SelectView.render("select_mobile.html", assigns)
    else
      InBeautyWeb.SelectView.render("select.html", assigns)
    end
  end
end
