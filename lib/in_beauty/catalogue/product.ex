defmodule InBeauty.Catalogue.Product do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  # alias InBeauty.MediaData.Image
  alias InBeauty.Catalogue.{Stock, ReservedStock}
  alias InBeauty.Payments.Cart
  alias InBeauty.Relations.FavoriteProduct

  @fields ~w(description gender name manufacturer)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type  :binary_id

  schema "products" do
    field :description, :string
    field :gender, Ecto.Enum, values: [:men, :women, :unisex] #TODO do it with ecto enums
    field :name, :string
    field :manufacturer, :string

    has_many :stocks, Stock,  on_delete: :delete_all, on_replace: :delete

    has_many :carts_products, FavoriteProduct,  on_delete: :delete_all, on_replace: :delete

    many_to_many :carts, Cart, join_through: "favorite_products", on_replace: :delete, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    stocks = attrs[:stocks] || attrs["stocks"]

    product
    |> InBeauty.Repo.preload([stocks: from(s in Stock, order_by: s.id)])
    |> cast(attrs, __MODULE__.__schema__(:fields))
    |> validate_required(@fields)
    |> maybe_cast_stocks(stocks)
  end

  defp maybe_cast_stocks(changeset, stocks), do:
    cast_assoc(changeset, :stocks, with: &Stock.changeset/2)
  defp maybe_cast_stocks(changeset, _), do:
    changeset
end
