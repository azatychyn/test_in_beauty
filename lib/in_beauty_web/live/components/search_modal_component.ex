defmodule InBeautyWeb.SearchModalComponent do
  use InBeautyWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
      <div
        id="<%= @id %>"
        phx-hook="Modal"
        class="flex flex-col slide-bottom fixed h-screen inset-0 overflow-auto z-50"
        phx-capture-click="close"
        phx-window-keydown="close"
        phx-key="escape"
        phx-target="#<%= @id %>"
        phx-page-loading
        >
        <div class="flex flex-col bg-gray-50 dark:bg-midnight-500 rounded-bl-2xl rounded-br-2xl">
          <%= live_patch raw("&times;"), to: @return_to, class: "phx-modal-close mr-8 text-6xl ml-auto" %>
          <%= live_component @socket, @component, @opts %>
        </div>
        <%= live_patch "", to: @return_to, class: "h-full w-full bg-midnight-700 bg-opacity-75" %>
      </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
