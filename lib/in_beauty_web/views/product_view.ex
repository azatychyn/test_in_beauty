defmodule InBeautyWeb.ProductView do
  use InBeautyWeb, :view

  defp load_more?(current_page, total_pages) do
    (current_page < total_pages)
  end

  def extract_image([stock | stocks]) do
    stock.image_path
  end
end
