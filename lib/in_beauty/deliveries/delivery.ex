defmodule InBeauty.Deliveries.Delivery do
  use Ecto.Schema

  import Ecto.Changeset

  @street_fields ~w(street_fias_id street street_type street_type_full)a
  @street_and_house_fileds ~w(street_fias_id street street_type street_type_full house_fias_id house house_type house_type_full)a
  @city_and_street_and_house_fileds ~w(city_fias_id ctiy city_type city_type_full city_kladr_id street_fias_id street street_type street_type_full house_fias_id house house_type house_type_full])a

  @fields ~w(date sdek_city_code delivery_type status user_id order_id price)a
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "deliveries" do
    field :region_fias_id, :string
    field :area_fias_id, :string
    field :city_fias_id, :string
    field :settlement_fias_id, :string
    field :street_fias_id, :string
    field :house_fias_id, :string
    field :flat_fias_id, :string
    field :region, :string
    field :area, :string
    field :city, :string
    field :settlement, :string
    field :street, :string
    field :house, :string
    field :flat, :string
    field :region_type, :string
    field :area_type, :string
    field :city_type, :string
    field :settlement_type, :string
    field :street_type, :string
    field :house_type, :string
    field :flat_type, :string
    field :region_type_full, :string
    field :area_type_full, :string
    field :city_type_full, :string
    field :settlement_type_full, :string
    field :street_type_full, :string
    field :house_type_full, :string
    field :flat_type_full, :string
    field :region_kladr_id, :string
    field :area_kladr_id, :string
    field :city_kladr_id, :string
    field :city_district_kladr_id, :string
    field :settlement_kladr_id, :string
    field :house_kladr_id, :string
    field :longitude, :float
    field :latitude, :float
    field :private_house, :boolean, default: false
    field :date, :date
    field :sdek_city_code, :integer
    field :delivery_type, Ecto.Enum, values: [:sdek_pickup, :sdek_courier, :in_beauty_courier, :in_beauty_pickup]
    field :status, :string
    field :price, :float
    field :period_min, :integer
    field :period_max, :integer

    embeds_one :delivery_point, InBeauty.Deliveries.DeliveryPoint

    belongs_to :user, User
    belongs_to :order, Order

    timestamps()
  end

  @doc false
  def changeset(delivery, attrs \\ %{}) do
    delivery_point = attrs["delivery_point"] || attrs[:delivery_point]

    delivery
    |> cast(attrs, @fields)
    |> apply_changes()
    |> cast(attrs, @fields)
    |> validate_private_house()
    |> validate_required([:date])
    |> put_embed(:delivery_point, delivery_point)
  end

  def final_changeset(delivery, attrs \\ %{}) do
    delivery_point = attrs["delivery_point"] || attrs[:delivery_point]

    delivery
    |> cast(attrs, @fields)
    |> apply_changes()
    |> cast(attrs, @fields)
    |> validate_private_house()
    |> validate_required([:date, :delivery_type])
    |> put_embed(:delivery_point, delivery_point)
  end

  def changeset(delivery, attrs, "house") do
    delivery
    |> cast(attrs, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> validate_required(@street_fields)
  end
  def changeset(delivery, attrs, "flat") do
    delivery
    |> cast(attrs, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> validate_required([:flat, :street, :house])
  end
  def changeset(delivery, attrs, _) do
    delivery
    |> cast(attrs, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
  end

    def private_house_changeset(changeset, attrs \\ %{}) do
      private_house = get_field(changeset, :private_house)

      changeset
      |> put_change(:private_house, !private_house)
      |> apply_changes()
      |> cast(attrs, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    end

    def from_changeset_to_struct(delivery, attrs \\ %{}) do
      delivery
      |> cast(attrs, @fields)
      |> apply_changes()
    end

    def validate_private_house(changeset) do
      private_house = get_field(changeset, :private_house)
      case private_house do
        false ->
          validate_required(changeset, [:flat])
        _ ->
          attrs = %{flat_fias_id: nil, flat: nil, flat_type: nil, flat_type_full: nil}
          cast(changeset, attrs, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
      end
    end

    def create_changeset(delivery, attrs \\ %{}) do
      delivery_point = (attrs["delivery_point"] || attrs[:delivery_point])
      |> IO.inspect()
      changeset =
        delivery
        |> cast(attrs, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
        |> validate_required([:price])
        |> put_embed(:delivery_point, delivery_point)
      delivery_type = get_field(changeset, :delivery_type)
      changeset
      |> validate_by_delivery_type(delivery_type)
    end

    defp validate_by_delivery_type(changeset, delivery_type) when delivery_type in ["in_beauty_courier", :in_beauty_courier, "sdek_courier", :sdek_courier] do
      changeset
      |> validate_private_house()
      |> validate_required([:street, :house, :date])
    end
    defp validate_by_delivery_type(changeset, delivery_type) when delivery_type in ["in_beauty_pickup", :in_beauty_pickup] do
      changeset
    end
    defp validate_by_delivery_type(changeset, delivery_type) when delivery_type in ["sdek_pickup", :sdek_pickup] do
      IO.inspect(changeset.data)
      changeset
      |> validate_required([:delivery_point], message: "Выберите пункт самовывоза")
    end
    defp validate_by_delivery_type(changeset, delivery_type) do
      changeset
      |> validate_required([:delivery_type], message: "Выберите способ доставки")
    end
end
