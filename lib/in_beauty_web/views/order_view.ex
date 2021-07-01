defmodule InBeautyWeb.OrderView do
  use InBeautyWeb, :view

  def active_delivery_type?(selected_type, type) do
    if selected_type == type,
      do: " bg-rose-200 ring-4 ring-offset-4 ring-rose-200",
      else: ""
  end
end
