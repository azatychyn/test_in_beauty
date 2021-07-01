defmodule InBeauty.Repo.Migrations.CreateReservedStocks do
  use Ecto.Migration

  def change do
    create table(:reserved_stocks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :quantity, :integer, null: false
      add :volume, :integer, null: false

      # add :product_id, references(:products, type: :binary_id), null: false
      add :stock_id, references(:stocks, type: :binary_id), null: false
      add :order_id, references(:orders, type: :binary_id), null: false

      timestamps()
    end

    create unique_index(:reserved_stocks, [:order_id, :stock_id, :volume])
  end
end
