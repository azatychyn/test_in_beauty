defmodule InBeauty.Repo.Migrations.CreateDeliveries do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE delivery_type AS ENUM ('sdek_pickup', 'sdek_courier', 'in_beauty_courier', 'in_beauty_pickup')"
    drop_query = "DROP TYPE delivery_type"
    execute(create_query, drop_query)

    create table(:deliveries, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :region_fias_id, :string
      add :area_fias_id, :string
      add :city_fias_id, :string
      add :settlement_fias_id, :string
      add :street_fias_id, :string
      add :house_fias_id, :string
      add :flat_fias_id, :string
      add :region, :string
      add :area, :string
      add :city, :string
      add :settlement, :string
      add :street, :string
      add :house, :string
      add :flat, :string
      add :region_type, :string
      add :area_type, :string
      add :city_type, :string
      add :settlement_type, :string
      add :street_type, :string
      add :house_type, :string
      add :flat_type, :string
      add :region_type_full, :string
      add :area_type_full, :string
      add :city_type_full, :string
      add :settlement_type_full, :string
      add :street_type_full, :string
      add :house_type_full, :string
      add :flat_type_full, :string
      add :region_kladr_id, :string
      add :area_kladr_id, :string
      add :city_kladr_id, :string
      add :city_district_kladr_id, :string
      add :settlement_kladr_id, :string
      add :house_kladr_id, :string
      add :longitude, :float
      add :latitude, :float
      add :private_house, :boolean, default: false
      add :date, :date
      add :sdek_city_code, :integer
      add :delivery_type, :delivery_type, null: false
      add :status, :string
      add :delivery_point, :map
      add :price, :float
      add :period_min, :integer
      add :period_max, :integer

      add :order_id, references(:orders, type: :binary_id)
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end
  end
end
