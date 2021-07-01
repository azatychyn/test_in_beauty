defmodule InBeauty.ProductFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `InBeauty.Catalogue` context.
  """
  alias InBeauty.Catalogue

  def valid_product_attrs() do
    %{
      description: "some description",
      id: "e81fb15b-b6b3-4d91-a18e-2ff75581b24e",
      gender: "men",
      name: "some name",
      manufacturer: "Some manufacturer"
    }
  end
  def update_product_attrs() do
    %{
      description: "some updated description",
      id: "e81fb15b-b6b3-4d91-a18e-2ff75581b24e",
      gender: "women",
      name: "some updated name",
      manufacturer: "Some upated manufacturer"
    }
  end
  def invalid_product_attrs() do
    %{
      description: nil,
      id: "invalid format",
      gender: nil,
      name: nil,
      manufacturer: nil
    }
  end

  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(valid_product_attrs())
      |> Catalogue.create_product()

    product
  end
end
