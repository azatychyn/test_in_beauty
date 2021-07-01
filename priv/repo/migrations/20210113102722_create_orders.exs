defmodule InBeauty.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext", "")

    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :patronymic, :string
      add :email, :citext, null: false
      add :phone_number, :string, null: false
      add :total_price, :float, null: false
      add :product_price, :float, null: false
      add :discount, :float, default: 0.0
      add :paid, :boolean, default: false
      add :comment, :string
      add :status, :string

      add :user_id, references(:users, type: :binary_id)

      timestamps()
    end

    create constraint("orders", :total_price_constraint, check: "total_price >= 0.0")
  end
end
