defmodule InBeauty.Repo.Migrations.CreateStocks do
  use Ecto.Migration

  def change do
    create table(:stocks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :image_path, :string, null: false
      add :price, :integer, null: false
      add :quantity, :integer, null: false
      add :volume,  :integer, null: false
      add :weight, :integer, null: false

      add :product_id, references(:products, type: :binary_id, on_delete: :delete_all), null: false
      timestamps()
    end
  end
end
