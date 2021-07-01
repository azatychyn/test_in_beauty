defmodule InBeauty.Deliveries.DeliveryPoint do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :code, :string
    field :name, :string
    field :city_code, :integer
    field :city, :string
    field :latitude, :float
    field :longitude, :float
    field :address, :string
    field :address_full, :string
    field :work_time, :string
    field :type, :string
    field :owner_code, :string
    field :is_handout, :boolean
    field :have_cashless, :boolean
    field :have_cash, :boolean
    field :allowed_cod, :boolean
  end

  @doc false
  def changeset(cart, attrs) do
    cart
    |> cast(attrs, __MODULE__.__schema__(:fields))
    |> validate_required(__MODULE__.__schema__(:fields))
  end
end
