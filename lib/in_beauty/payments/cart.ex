defmodule InBeauty.Payments.Cart do
  use Ecto.Schema

  import Ecto.Changeset
   #TODO dlete old carts and maybe add a field that wouldbe register an ani use of the cart
  alias InBeauty.Catalogue.{Product, Stock}
  alias InBeauty.Accounts.User
  alias InBeauty.Relations.StockCart
  alias InBeauty.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "carts" do
    #TODO should remove anon if not user
    field :anon, :boolean, default: false
    field :product_count, :integer, virtual: true
    field :total_price, :float, virtual: true
    field :session_id, :binary_id

    belongs_to :user, User

    has_many :stocks_carts, StockCart, on_delete: :delete_all, on_replace: :delete

    many_to_many :stocks, Stock, join_through: "stocks_carts",  on_replace: :delete, on_delete: :delete_all
    many_to_many :favorite_products, Product, join_through: "favorite_products", on_replace: :delete, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(cart, attrs) do
    cart
    |> cast(attrs, [:id, :total_price, :product_count, :anon, :user_id, :session_id])
    |> unique_constraint(:session_id)
    |> validate_required([:anon, :session_id])
  end
end
