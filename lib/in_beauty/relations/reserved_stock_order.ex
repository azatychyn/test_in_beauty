defmodule InBeauty.Relations.ReservedStockOrder do
  @typedoc """
      Module that provides ReservedStockOrder schema and its changesets
  """
  use Ecto.Schema

  import Ecto.Changeset

  # @primary_key {:id, :binary_id, autogenerate: true}
  # @foreign_key_type :binary_id

  # schema "reserved_stocks_orders" do
  #   field :quantity, :integer, default: 0
  #   field :volume, :integer

  #   belongs_to :order, InBeauty.Payments.Order
  #   belongs_to :reserved_stock, InBeauty.Catalogue.ReservedStock
  # end

  # @doc false
  # def changeset(reserved_stock_order, attrs) do
  #   reserved_stock_order
  #   |> cast(attrs, [:order_id, :reserved_stock_id, :quantity, :volume])
  #   |> validate_required([:reserved_stock_id, :volume, :quantity])
  #   |> unique_constraint([:order_id, :reserved_stock_id, :quantity, :volume])
  # end
end
