defmodule InBeautyWeb.MapModalComponent do
  use InBeautyWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
      <div

        id="<%= @id %>"
        phx-hook="Modal"
        class="slide-bottom fixed min-w-screen h-full inset-0 overflow-hidden z-50 bg-white dark:bg-midnight-500"
        phx-capture-click="close"
        phx-window-keydown="close"
        phx-key="escape"
        phx-target="#<%= @id %>"
        phx-page-loading
        >
        <div class="flex flex-col h-full dark:bg-opacity-30">
          <%= live_patch raw("&times;"), to: @return_to, class: "phx-modal-close block absolute right-2 top-2 ml-auto w-max mr-8 text-6xl" %>
          <%= live_component @socket, @component, @opts %>
        </div>
      </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
