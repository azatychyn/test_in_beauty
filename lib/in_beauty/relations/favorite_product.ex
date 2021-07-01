defmodule InBeauty.Relations.FavoriteProduct do
  @typedoc """
      Module that provides FavoriteProduct schema and its changesets
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id

  schema "favorite_products" do
    belongs_to :cart, InBeauty.Payments.Cart, primary_key: true
    belongs_to :product, InBeauty.Catalogue.Product,  primary_key: true
  end

  @doc false
  def changeset(favorite_product, attrs) do
    favorite_product
    |> cast(attrs, [:cart_id, :product_id])
    |> validate_required([:cart_id, :product_id])
    |> unique_constraint([:cart_id, :product_id])
  end
end
