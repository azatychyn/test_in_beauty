defmodule InBeauty.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE role_type AS ENUM ('user', 'admin', 'anon')"
    drop_query = "DROP TYPE role_type"

    execute("CREATE EXTENSION IF NOT EXISTS citext", "")
    execute(create_query, drop_query)

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      add :role, :role_type, null: false
      add :first_name, :string, null: false
      add :last_name, :string
      add :patronymic, :string
      add :phone_number, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:phone_number])

    create table(:users_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
