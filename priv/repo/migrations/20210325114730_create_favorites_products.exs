defmodule InBeauty.Repo.Migrations.CreateFavoritesProducts do
  use Ecto.Migration

  def change do
    create table(:favorite_products, primary_key: false) do
      add :cart_id, references(:carts, type: :binary_id, on_delete: :delete_all), primary_key: true, null: false
      add :product_id, references(:products, type: :binary_id, on_delete: :delete_all), primary_key: true, null: false
    end
  end
end
