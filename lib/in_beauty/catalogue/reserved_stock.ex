defmodule InBeauty.Catalogue.ReservedStock do
  use Ecto.Schema

  import Ecto.Changeset

  # alias InBeauty.MediaData.Image
  alias InBeauty.Catalogue.Stock
  alias InBeauty.Payments.Order

  @fields ~w(stock_id order_id quantity volume)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type  :binary_id

  schema "reserved_stocks" do
    field :quantity, :integer
    field :volume, :integer

    belongs_to :stock, Stock
    belongs_to :order, Order

    timestamps()
  end

  @doc false
  def changeset(stock, attrs) do
    stock
    |> cast(attrs, __MODULE__.__schema__(:fields))
    |> validate_required(@fields) #TODO add all fields to validate
  end
end
