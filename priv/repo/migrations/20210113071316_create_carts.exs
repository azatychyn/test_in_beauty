defmodule InBeauty.Repo.Migrations.CreateCarts do
  use Ecto.Migration

  def up do
    create table(:carts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      # add :total_price, :integer, default: 0
      # add :product_count, :integer, default: 0, null: false
      add :anon, :boolean, default: false, null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)
      add :session_id, :binary_id

      timestamps()
    end

    create unique_index(:carts, [:session_id])
  end

  def down do
    drop_if_exists unique_index(:carts, [:session_id])
    drop table(:carts)
  end
end
