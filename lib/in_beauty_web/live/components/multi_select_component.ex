defmodule InBeautyWeb.MultiSelectComponent do
  use InBeautyWeb, :live_component

  @defaults %{
    variants: [],
    selected_variants: [],
    placeholder: ""
  }

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, @defaults)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do

    if assigns.device == "mobile" do
      InBeautyWeb.MultiSelectView.render("multi_select_mobile.html", assigns)
    else
      InBeautyWeb.MultiSelectView.render("multi_select.html", assigns)
    end
  end
end
