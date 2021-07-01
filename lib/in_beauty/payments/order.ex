defmodule InBeauty.Payments.Order do
  use Ecto.Schema

  import Ecto.Changeset
  alias InBeauty.Accounts.User
  alias InBeauty.Repo
  alias InBeauty.Relations.StockOrder
  alias InBeauty.Catalogue.Stock
  alias InBeauty.Deliveries.Delivery
  alias InBeauty.Catalogue.ReservedStock

  @fields ~w(first_name last_name paid status product_price total_price discount)a
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "orders" do
    field :comment, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :patronymic, :string
    field :phone_number, :string
    field :paid, :boolean, default: false
    field :total_price, :float
    field :status, :string
    field :product_price, :float
    field :discount, :float, default: 0.0

    belongs_to :user, User

    has_one :delivery, Delivery, on_replace: :delete

    has_many :stocks_orders, StockOrder, on_replace: :delete
    has_many :reserved_stocks, ReservedStock, on_replace: :delete

    many_to_many :stocks, Stock, join_through: "stocks_orders",  on_replace: :delete


    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, __MODULE__.__schema__(:fields))
    |> validate_required(@fields)
    |> validate_email()
    |> validate_phone_number()
    |> check_constraint(:total_price, name: :total_price_constraint)
    # |> maybe_cast_stocks_orders(attrs)
    |> maybe_cast_reserved_stocks_orders(attrs)
  end

  defp validate_phone_number(changeset) do
    changeset
    |> format_phone_number()
    |> validate_required([:phone_number])
    |> validate_length(:phone_number, min: 11, max: 11)
    |> validate_format(:phone_number, ~r/^7[0-9]*$/, message: "must start with +7..........")
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
  end

  defp format_phone_number(%{changes: %{phone_number: phone_number}} = changeset) do
    phone_number = String.replace(phone_number, ~r/(\s)?(\()?(\))?(\-)?(\+)?/, "")
    put_change(changeset, :phone_number, phone_number)
  end
  defp format_phone_number(changeset), do: changeset

  # defp maybe_cast_stocks_orders(changeset, %{"stocks_orders" => _stocks_orders}), do:
  #   cast_assoc(changeset, :stocks_orders)
  # defp maybe_cast_stocks_orders(changeset, _), do:
  #   changeset
  defp maybe_cast_reserved_stocks_orders(changeset, %{"reserved_stocks" => reserved_stocks}), do:
    cast_assoc(changeset, :reserved_stocks)
  defp maybe_cast_reserved_stocks_orders(changeset, _), do:
    changeset
end
