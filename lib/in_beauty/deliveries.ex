defmodule InBeauty.Deliveries do
  @moduledoc """
  The Deliveries context.
  """

  import Ecto.Query, warn: false
  alias InBeauty.Repo

  alias InBeauty.Deliveries.Delivery
  alias InBeauty.Repo
  alias InBeauty.Relations.StockDelivery
  alias InBeauty.Relations.StockAddress

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(InBeauty.PubSub, @topic)
  end

  def subscribe(delivery_id) do
    Phoenix.PubSub.subscribe(InBeauty.PubSub, @topic <> "#{delivery_id}")
  end

  @doc """
  Returns the list of deliveries.

  ## Examples

      iex> list_deliveries()
      [%Delivery{}, ...]

  """
  def list_deliveries do
    Repo.all(Delivery)
  end

  @doc """
  Gets a single delivery by params.

  ## Examples

      iex> get_delivery([field: value])
      %Delivery{}

      iex> get_delivery([field: bad_value])
      nil

  """
  def get_delivery_by(params), do: Repo.get_by(Delivery, params)

  @doc """
  Gets a single delivery.

  Raises `Ecto.NoResultsError` if the Delivery does not exist.

  ## Examples

      iex> get_delivery!(123)
      %Delivery{}

      iex> get_delivery!(456)
      ** (Ecto.NoResultsError)

  """
  def get_delivery!(id), do: Repo.get!(Delivery, id)

  @doc """
  Creates a delivery.

  ## Examples

      iex> create_delivery(%{field: value})
      {:ok, %Delivery{}}

      iex> create_delivery(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_delivery(delivery, attrs \\ %{}) do
    delivery
    |> Delivery.create_changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:delivery, :created])
  end

  @doc """
  Updates a delivery.

  ## Examples

      iex> update_delivery(delivery, %{field: new_value})
      {:ok, %Delivery{}}

      iex> update_delivery(delivery, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_delivery(%Delivery{} = delivery, attrs) do
    delivery
    |> Delivery.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:delivery, :updated])
  end

  @doc """
  Deletes a delivery.

  ## Examples

      iex> delete_delivery(delivery)
      {:ok, %Delivery{}}

      iex> delete_delivery(delivery)
      {:error, %Ecto.Changeset{}}

  """
  def delete_delivery(%Delivery{} = delivery) do
    Repo.delete(delivery)
    |> notify_subscribers([:delivery, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking delivery changes.

  ## Examples

      iex> change_delivery(delivery)
      %Ecto.Changeset{data: %Delivery{}}

  """
  def change_delivery(delivery, attrs \\ %{}) do
    Delivery.changeset(delivery, attrs)
  end

    @doc """
  Returns an `%Ecto.Changeset{}` for tracking delivery changes.

  ## Examples

      iex> create_change_delivery(delivery)
      %Ecto.Changeset{data: %Delivery{}}

  """
  def create_change_delivery(delivery, attrs \\ %{}) do
    Delivery.create_changeset(delivery, attrs)
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(InBeauty.PubSub, @topic, {__MODULE__, event, result})
    Phoenix.PubSub.broadcast(InBeauty.PubSub, @topic <> "#{result.id}", {__MODULE__, event, result})
    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
