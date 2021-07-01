defmodule InBeauty.Catalogue.Stock do
  use Ecto.Schema

  import Ecto.Changeset

  # alias InBeauty.MediaData.Image
  alias InBeauty.Catalogue.Product
  alias InBeauty.Catalogue.ReservedStock

  @fields ~w(image_path price quantity volume weight)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type  :binary_id

  schema "stocks" do
    field :image_path, :string
    field :price, :integer
    field :quantity, :integer
    field :volume, :integer
    field :weight, :integer
    field :delete, :boolean, virtual: true

    belongs_to :product, Product

    has_many :reserved_stocks, ReservedStock, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(stock, attrs) do
    stock
    |> cast(attrs, __MODULE__.__schema__(:fields))
    |> validate_required(@fields) #TODO add all fields to validate
    |> maybe_mark_for_deletion()
  end

  defp maybe_mark_for_deletion(%{data: %{id: nil}} = changeset), do: changeset
  defp maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
