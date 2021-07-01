defmodule InBeauty.Repo.Migrations.CreateFeedBackMessages do
  use Ecto.Migration

  def change do
    create table(:feedback_messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :contact, :string, null: false
      add :message, :text, null: false

      timestamps()
    end
  end
end
