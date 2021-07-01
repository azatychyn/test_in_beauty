defmodule InBeautyWeb.PaginationComponent do
  @moduledoc """

    <%= live_component(@socket, PaginationComponent,
      required
    )
    %>
  """
  use InBeautyWeb, :live_component

  import Process, only: [send_after: 3]

  alias InBeauty.Accounts
  alias InBeauty.Accounts.User

  @link_classes %{
    active: "block w-12 h-12 mx-1 px-4 bg-rose-300 dark:bg-denim-200 dark:text-rose-100 rounded-2xl flex justify-center items-center pointer-events-none",
    common: "block w-12 h-12 mx-1 px-4 bg-rose-100 hover:bg-rose-200 dark:bg-denim-300 dark:hover:bg-denim-200 dark:text-rose-100 rounded-2xl flex justify-center items-center",
    disabled: "block h-12 mx-1 px-4 bg-gray-400 dark:bg-denim-300 dark:text-rose-100 rounded-2xl flex justify-center items-center pointer-events-none",
    common_prev_or_next: "block h-12 mx-1 px-4 bg-rose-100 hover:bg-rose-200 dark:bg-denim-300 dark:hover:bg-denim-200 dark:text-rose-100 rounded-2xl flex justify-center items-center"
  }

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~L"""
      <ul class="flex">

          <li>
          <a href="#<%= #{@page_number - 1} %>" class="<%= put_class_by_page_number(@page_number - 1) %>">
            Previous
          </a>
            <%= pagination_link(
              @socket,
              "Previous",
              @page_number - 1,
              @page_size,
              put_class_by_page_number(@page_number - 1),
              @filter_options
            ) %>
          </li>

        <%= for i <- (@page_number - 2)..(min(@page_number + 4, @total_pages)), i > 0 do %>
          <li>
            <a href="#<%= #{i} %>" class="<%= put_class_by_page_number(i == @page_number) %>">
              <%= i %>
            </a>
          </li>
        <% end %>
        <li>
          <%= pagination_link(
              @socket,
              "Next",
              @page_number + 1,
              @page_size,
              put_class_by_page_number(@page_number - 1),
              @filter_options
            ) %>
        </li>
      </ul>
    """
  end

  defp put_class_by_page_number(true), do: @link_classes.active
  defp put_class_by_page_number(0), do: @link_classes.disabled
  defp put_class_by_page_number(false), do: @link_classes.common
  defp put_class_by_page_number(_), do: @link_classes.common_prev_or_next

  defp pagination_link(socket, text, page, page_size, class, filter_options) do
    assigns =  %{}
    options =
      filter_options
      |> Map.put(:page, page)
      |> Map.put(:page_size, page_size)
      |> Map.to_list()

    live_patch(text,
      to: "##{page}",
        # Routes.product_admin_index_path(
        #   socket,
        #   :index,
        #   options
        # ),
      class: class
    )
    ~L"""

    <a>some link</a>
    """
  end
end
