defmodule InBeautyWeb.AccountComponent do
  @moduledoc """
  This is a general modal component with a title, body text, and either
  one or two buttons. Many aspects of the modal can be customized, including
  colors, button labels, and title and body text. Application wide defaults
  are specified for the colors and button texts.

  A required action string and optional parameter are provided for each
  button when the modal is initialized. These will be returned to the caller
  when the corresponding button is clicked.

  The caller must have message handlers defined for each button that takes
  the given action and parameter for each button. For example:

    def handle_info(
        {AccountComponent, :button_pressed,
         %{action: "remove-item-confirmed", param: display_order_of_item}},
        socket
      )

  Also, the caller should have a 'modal_closed' event handler that will be called when the
  modal is closed with a click-away or escape key press.

    def handle_info(
        {AccountComponent, :modal_closed, %{id: "confirm-heading-removal"}},
        socket
      ) do

  This is a stateful component, so you MUST specify an id when calling
  live_component.

  The display of the modal is determined by the required show assign.

  The component can be called like:

  <%= live_component(@socket, AccountComponent,
      id: "confirm-delete-member",
      show: @live_action == :delete_member,
      title: "Delete Member",
      body: "Are you sure you want to delete team member?",
      right_button: "Delete",
      right_button_action: "delete-member",
      left_button: "Cancel",
      left_button_action: "cancel-delete-member")
  %>
  """

  use InBeautyWeb, :live_component
  import Process, only: [send_after: 3]

  @defaults %{
    current_user: %{
      first_name: "",
      last_name: "",
      email: "",
      phone_number: "799999999999",
    },
    show: false,
    enter_duration: 300,
    leave_duration: 200,
    background_color: "bg-gray-500",
    background_opacity: "opacity-75",
    title_color: "text-gray-900",
    body_color: "text-gray-500",
    left_button: nil,
    left_button_action: nil,
    left_button_param: nil,
    right_button: nil,
    right_button_color: "red",
    right_button_action: nil,
    right_button_param: nil
  }

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, @defaults)}
  end

  # @impl Phoenix.LiveComponent
  # def handle_event("modal-closed", _params, socket) do
  #   # Handle event fired from Modal hook leave_duration-milliseconds
  #   # afer open transitions to false.
  #   send(self(), {__MODULE__, :modal_closed, %{id: socket.assigns.id}})

  #   {:noreply, socket}
  # end

  # # Fired when user clicks right button on modal
  # def handle_event(
  #       "right-button-click",
  #       _params,
  #       %{
  #         assigns: %{
  #           right_button_action: right_button_action,
  #           right_button_param: right_button_param,
  #           leave_duration: leave_duration
  #         }
  #       } = socket
  #     ) do
  #   send(
  #     self(),
  #     {__MODULE__, :button_pressed, %{action: right_button_action, param: right_button_param}}
  #   )

  #   send_after(self(), {__MODULE__, :modal_closed, %{id: socket.assigns.id}}, leave_duration)

  #   {:noreply, socket}
  # end

  # def handle_event(
  #       "left-button-click",
  #       _params,
  #       %{
  #         assigns: %{
  #           left_button_action: left_button_action,
  #           left_button_param: left_button_param,
  #           leave_duration: leave_duration
  #         }
  #       } = socket
  #     ) do
  #   send(
  #     self(),
  #     {__MODULE__, :button_pressed, %{action: left_button_action, param: left_button_param}}
  #   )

  #   send_after(self(), {__MODULE__, :modal_closed, %{id: socket.assigns.id}}, leave_duration)

  #   {:noreply, socket}
  # end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~L"""
      <div
        class="flex flex-col text-gray-800 bg-lavender-blush px-8 py-6 w-3/4 mx-auto rounded-2xl shadow-lg mt-12
        "
        x-show="isProfileOpen"
        x-transition:enter="transition ease-out duration-1000"
        x-transition:enter-start="opacity-0 transform translate-x-32"
        x-transition:enter-end="opacity-100 transform translate-x-0"
        x-transition:leave="transition ease-in duration-300"
        x-transition:leave-start="opacity-100 transform translate-x-0"
        x-transition:leave-end="opacity-0 transform translate-x-32"
      >
          <div class="flex justify-center items-center">
              <a class="px-2 py-1  text-xl  rounded" href="#"><%= "#{@current_user.first_name} #{@current_user.last_name}" %></a>
          </div>
          <div class="bg-white grid grid-cols-1 gap-3 ring-1 ring-black ring-opacity-5 mt-6 p-6 my-3 rounded-2xl">
            <div class=" flex items-center justify-between ">
              <h1 class="  font-bold text-gray-600  ">
                Profile Info
              </h1>
              <div class="flex  items-center rounded-full dark:text-blue-100 dark:bg-blue-500">
                <%= InBeautyWeb.IconView.render InBeautyWeb.IconView, "edit.html"  %>
                <span class="text-lg ml-2">edit</span>
              </div>
            </div>

            <div class="flex justify-between">
              <div class="min-w-0 text-base font-medium ">
                email
              </div>
              <div class="min-w-0 text-base font-medium ">
              <%= @current_user.email %>
              </div>
            </div>
            <div class="flex justify-between">
              <div class="min-w-0 text-base font-medium ">
                phone number
              </div>
              <div class="min-w-0 text-base font-medium ">
              <%= @current_user.phone_number %>
              </div>
            </div>
          </div>
          <div class="bg-white grid grid-cols-1 gap-3 ring-1 ring-black ring-opacity-5 mt-6 p-6 my-3 rounded-2xl">
            <div class=" flex items-center justify-between ">
              <h1 class="  font-bold text-gray-600  ">
                Delivery Info
              </h1>
              <div class="flex  items-center rounded-full dark:text-blue-100 dark:bg-blue-500">
                <%= InBeautyWeb.IconView.render InBeautyWeb.IconView, "edit.html"  %>
                <span class="text-lg ml-2">edit</span>
              </div>
            </div>

            <div class="flex justify-between">
              <div class="min-w-0 text-base font-medium">
                street and house
              </div>
              <div class="min-w-0 text-base font-medium">
                <%= "#{@current_user.delivery.street} #{@current_user.delivery.house}" %>
              </div>
            </div>
            <div class="flex justify-between">
              <div class="min-w-0 text-base font-medium">
                flat
              </div>
              <div class="min-w-0 text-base font-medium">
                <%= @current_user.delivery.flat %>
              </div>
            </div>
            <div class="flex justify-between">
              <div class="min-w-0 text-base font-medium">
                city
              </div>
              <div class="min-w-0 text-base font-medium">
              <%= @current_user.delivery.city %>
              </div>
            </div>
          </div>

          <div class="grid gap-6 mb-8 md:grid-cols-2">
            <div class="min-w-0 rounded-2xl ring-1 ring-black ring-opacity-5 overflow-hidden bg-white dark:bg-gray-800">
              <div class="p-4 flex items-center">
                <div class="p-3 rounded-full text-blue-500 dark:text-blue-100 mr-4">
                <%=   render InBeautyWeb.IconView, "cart.html", []  %>
                </div>
                  <p class="mb-2 text-sm font-medium text-gray-600">
                   Cart
                  </p>

              </div>
            </div>
            <div class="min-w-0 rounded-lg ring-1 ring-black ring-opacity-5 overflow-hidden bg-white dark:bg-gray-800">
              <div class="p-4 flex items-center">
                <div
                  class="p-3 rounded-full text-teal-500 dark:text-teal-100 bg-teal-100 dark:bg-teal-500 mr-4"
                >
                  <svg fill="currentColor" viewBox="0 0 20 20" class="w-5 h-5">
                    <path
                      fill-rule="evenodd"
                      d="M18 5v8a2 2 0 01-2 2h-5l-5 4v-4H4a2 2 0 01-2-2V5a2 2 0 012-2h12a2 2 0 012 2zM7 8H5v2h2V8zm2 0h2v2H9V8zm6 0h-2v2h2V8z"
                      clip-rule="evenodd"
                    ></path>
                  </svg>
                </div>

                  <p class="mb-2 text-sm font-medium text-gray-600">
                    My Orders
                  </p>


              </div>
            </div>
          </div>

          <div class="flex justify-between items-center mt-4">
              <div class="flex items-center">
                  <img src="https://images.unsplash.com/photo-1502791451862-7bd8c1df43a7?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60"
                      class="w-8 h-8 object-cover rounded-full" alt="avatar">
                  <a class="  text-sm mx-3" href="#">LOG OUT</a>
              </div>
              <span class="font-light text-sm text-gray-600"></span>
          </div>
      </div>


    """
  end
end
