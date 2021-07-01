defmodule InBeauty.Repo.Migrations.CreateStocksCarts do
  use Ecto.Migration

  def change do
    create table(:stocks_carts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :quantity, :integer, null: false
      add :volume, :integer, null: false

      add :cart_id, references(:carts, type: :binary_id, on_delete: :delete_all), null: false
      add :stock_id, references(:stocks, type: :binary_id, on_delete: :delete_all), null: false
    end

    create unique_index(:stocks_carts, [:cart_id, :stock_id, :quantity, :volume])
    create unique_index(:stocks_carts, [:cart_id, :stock_id, :volume])
  end
end
