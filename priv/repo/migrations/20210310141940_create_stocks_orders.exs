defmodule InBeauty.Repo.Migrations.CreateStocksOrders do
  use Ecto.Migration

  def change do
    create table(:stocks_orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :quantity, :integer, null: false
      add :volume, :integer, null: false

      add :order_id, references(:orders, type: :binary_id), null: false
      add :stock_id, references(:stocks, type: :binary_id), null: false
    end

    create unique_index(:stocks_orders, [:order_id, :stock_id, :quantity, :volume])
    create unique_index(:stocks_orders, [:order_id, :stock_id, :volume])
  end
end
