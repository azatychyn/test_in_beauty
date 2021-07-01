defmodule InBeautyWeb.InputComponent do
  @moduledoc """

    <%= live_component(@socket, InputComponent,
      required
    )
    %>
  """
  use InBeautyWeb, :live_component

  import Process, only: [send_after: 3]

  alias InBeauty.Accounts
  alias InBeauty.Accounts.User

  defp define_type(field) do
    case field do
      :url -> :url
      :email -> :email
      :search -> :search
      :phone_number -> :tel
      :price -> :number
      :volume -> :number
      :quantity -> :number
      :password -> :password
      :password_confirmation -> :password
      _ -> :text
    end
  end

  defp mobile?(mobile) do
    if mobile, do: "_mobile", else: ""
  end

  # TODO refactote with new functions

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~L"""
      <%= cond do %>
        <%= define_type(@field) == :number -> %>
          <div>
            <%= label @form, @field, [
                  class: "block mb-3 ml-1 text-xl font-semibold tracking-widest"
                  ]
                  do %>
              <%= @label %>
              <%= error_wrapper(@form, @field) %>
            <% end %>

            <%= text_input(
                  @form,
                  @field,
                  [
                    "phx-hook": "NumberInput",
                    "phx-update": "ignore",
                    "phx-debounce": "2000",
                    inputmode: "numeric",
                    pattern: "[0-9]*",
                    required: @required,
                    class: "w-full p-4 text-lg font-medium dark:text-midnight-500 rounded-2xl focus:outline-none focus:ring focus:ring-bright-pink-dribble dark:focus:ring-rose-100 focus:bg-white dark:bg-rose-100 dark:focus:bg-white"
                  ]
                )
            %>
          </div>
        <% define_type(@field) == :password -> %>
          <div x-data="{ show: true }"
            x-transition:enter="transition ease-out duration-300"
            x-transition:enter-start="height-96 transform scale-90"
            x-transition:enter-end="opacity-100 transform scale-100"
            x-transition:leave="transition ease-in duration-300"
            x-transition:leave-start="opacity-100 transform scale-100"
            x-transition:leave-end="opacity-0 transform scale-90"
          >
            <label
              class="block mb-3 ml-1 text-xl font-semibold tracking-widest"
              for= <%= "#{@id_prefix}_#{@form.id}_#{@field}#{mobile?(@mobile)}" %>
            >
              <%= @label %>
              <%= error_wrapper(@form, @field) %>
            </label>
            <div class="relative">
              <input
                id=<%= "#{@id_prefix}_#{@form.id}_#{@field}#{mobile?(@mobile)}"%>
                autocomplete="current-password"
                name=<%= input_name(@form, @field) %>
                phx-debounce="2000"
                :type="show ? 'password' : 'text'"
                <%= if @required, do: "required" %>
                class="w-full px-6 py-4 text-lg font-medium dark:text-midnight-500 rounded-2xl focus:outline-none focus:ring focus:ring-bright-pink-dribble dark:focus:ring-rose-100 focus:bg-white dark:bg-rose-100 dark:focus:bg-white"
                value=<%= input_value(@form, @field) %>
              >
              <div class="absolute right-0 sm:right-12 bottom-0.5 text-sm p-4">

                <svg class="h-6 text-gray-700" fill="none" @click="show = !show"
                  :class="{'hidden': !show, 'block':show }" xmlns="http://www.w3.org/2000/svg"
                  viewbox="0 0 576 512">
                  <path fill="currentColor"
                    d="M572.52 241.4C518.29 135.59 410.93 64 288 64S57.68 135.64 3.48 241.41a32.35 32.35 0 0 0 0 29.19C57.71 376.41 165.07 448 288 448s230.32-71.64 284.52-177.41a32.35 32.35 0 0 0 0-29.19zM288 400a144 144 0 1 1 144-144 143.93 143.93 0 0 1-144 144zm0-240a95.31 95.31 0 0 0-25.31 3.79 47.85 47.85 0 0 1-66.9 66.9A95.78 95.78 0 1 0 288 160z">
                  </path>
                </svg>

                <svg class="h-6 text-gray-700" fill="none" @click="show = !show"
                  :class="{'block': !show, 'hidden':show }" xmlns="http://www.w3.org/2000/svg"
                  viewbox="0 0 640 512">
                  <path fill="currentColor"
                    d="M320 400c-75.85 0-137.25-58.71-142.9-133.11L72.2 185.82c-13.79 17.3-26.48 35.59-36.72 55.59a32.35 32.35 0 0 0 0 29.19C89.71 376.41 197.07 448 320 448c26.91 0 52.87-4 77.89-10.46L346 397.39a144.13 144.13 0 0 1-26 2.61zm313.82 58.1l-110.55-85.44a331.25 331.25 0 0 0 81.25-102.07 32.35 32.35 0 0 0 0-29.19C550.29 135.59 442.93 64 320 64a308.15 308.15 0 0 0-147.32 37.7L45.46 3.37A16 16 0 0 0 23 6.18L3.37 31.45A16 16 0 0 0 6.18 53.9l588.36 454.73a16 16 0 0 0 22.46-2.81l19.64-25.27a16 16 0 0 0-2.82-22.45zm-183.72-142l-39.3-30.38A94.75 94.75 0 0 0 416 256a94.76 94.76 0 0 0-121.31-92.21A47.65 47.65 0 0 1 304 192a46.64 46.64 0 0 1-1.54 10l-73.61-56.89A142.31 142.31 0 0 1 320 112a143.92 143.92 0 0 1 144 144c0 21.63-5.29 41.79-13.9 60.11z">
                  </path>
                </svg>
              </div>
            </div>
          </div>

        <% define_type(@field) == :tel -> %>
          <div>
            <%= label @form, @field, [
                  class: "block mb-3 ml-1 text-xl font-semibold tracking-widest"
                  ]
                  do %>
              <%= @label %>
              <%= error_wrapper(@form, @field) %>
            <% end %>
            <%= telephone_input(
                  @form,
                  @field,
                  [
                    "phx-debounce": "1500",
                    required: @required,
                    class: "w-full p-4 text-lg font-bold dark:text-midnight-500 rounded-2xl focus:outline-none focus:ring focus:ring-bright-pink-dribble dark:focus:ring-rose-100 focus:bg-white dark:bg-rose-100 dark:focus:bg-white",
                    "phx-hook": "PhoneNumber",
                    "phx-update": "ignore"
                  ]
                )
            %>
          </div>
        <% true -> %>
          <div>
            <%= label @form, @field, [
                  class: "block mb-3 ml-1 text-xl font-semibold tracking-widest"
                  ]
                  do %>
              <%= @label %>
              <%= error_wrapper(@form, @field) %>
            <% end %>

            <%= text_input(
                  @form,
                  @field,
                  [
                    "phx-debounce": "2000",
                    required: @required,
                    class: "w-full p-4 text-lg font-medium dark:text-midnight-500 rounded-2xl focus:outline-none focus:ring focus:ring-rose-300 dark:focus:ring-rose-100 focus:bg-white dark:bg-rose-100 dark:focus:bg-white"
                  ]
                )
            %>
          </div>
      <% end %>
    """
  end
end
