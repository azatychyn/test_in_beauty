defmodule InBeauty.Repo.Migrations.CreatePorducts do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE gender_type AS ENUM ('men', 'women', 'unisex')"
    drop_query = "DROP TYPE gender_type"
    execute(create_query, drop_query)

    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :text, null: false
      add :gender, :gender_type, null: false
      add :name, :string, null: false
      add :manufacturer, :string, null: false

      timestamps()
    end
  end
end
