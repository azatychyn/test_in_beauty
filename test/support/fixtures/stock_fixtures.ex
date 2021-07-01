defmodule InBeauty.StockFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `InBeauty.Catalogue` context.
  """
  alias InBeauty.Catalogue
  def valid_stock_attrs() do
    %{
      id: "e81fb15b-b6b3-4d91-a18e-2ff75581b24e",
      image_path: "/uploads/some_file",
      price: 1500,
      quantity: 4,
      volume: 50,
      weight: 50
    }
  end
  def update_stock_attrs() do
    %{
      id: "e81fb15b-b6b3-4d91-a18e-2ff75581b24e",
      image_path: "/uploads/another_file",
      price: 1800,
      quantity: 5,
      volume: 100,
      weight: 100
    }
  end
  def invalid_stock_attrs() do
    %{
      id: "invalid format",
      image_path: nil,
      price: nil,
      product_id: nil,
      quantity: nil,
      volume: nil,
      weight: nil
    }
  end

  def stock_fixture(attrs \\ %{}) do
    {:ok, stock} =
      attrs
      |> Enum.into(valid_stock_attrs())
      |> Catalogue.create_stock()

    stock
  end
end
