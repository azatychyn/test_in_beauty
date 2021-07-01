defmodule InBeautyWeb.DatePickerComponent do
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
    ~L"""
      <%= f = form_for @changeset, "#", @handle_events ++ [phx_target: @target, class: "w-full flex flex-col"] %>
      <%= error_wrapper f, :date %>
        <ul class="w-full flex justify-around rounded-2xl mt-2">
          <%= for date <- @variants do %>
            <li
              class="flex flex-col items-center justify-center w-24 h-24 rounded-2xl bg-rose-100 first:ml-0 ml-4 hover:bg-rose-200
                  <%= if get_changeset_field(@changeset, :date) == date, do: "bg-rose-200" %>
              "
            >
              <label class="w-full h-full flex flex-col align-center justify-center text-xl text-gray-700 dark:text-gray-100 group-hover:text-gray-700 text-center cursor-pointer">
                <div><%= get_week_name(date) %></div>
                <div><%= date.day %>.<%= date.month%></div>
                <%= radio_button(f, :date, date, class: "appearance-none", required: true) %>
              </label>
            </li>
          <% end %>
        </ul>
      </form>
    """
  end

  def get_week_name(date) do
    date
    |> Date.day_of_week()
    |> week_name()
  end

  def week_name(1), do: :mon
  def week_name(2), do: :tue
  def week_name(3), do: :wed
  def week_name(4), do: :thu
  def week_name(5), do: :fri
  def week_name(6), do: :sat
  def week_name(7), do: :sun
end
