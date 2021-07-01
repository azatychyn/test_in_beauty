defmodule InBeautyWeb.ModalComponent do
  use InBeautyWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
      <div
        id="<%= @id %>"
        phx-hook="Modal"
        class="slide-bottom fixed min-w-screen h-full inset-0 overflow-auto z-50 bg-gray-900 dark:bg-midnight-500"
        phx-capture-click="close"
        phx-window-keydown="close"
        phx-key="escape"
        phx-target="#<%= @id %>"
        phx-page-loading
        >
        <div class="h-full dark:bg-opacity-30">
          <%= live_patch raw("&times;"), to: @return_to, class: "phx-modal-close mr-8 text-6xl" %>
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
