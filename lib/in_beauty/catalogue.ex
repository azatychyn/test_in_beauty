defmodule InBeauty.Catalogue do
  @moduledoc """
  The Catalogue context.
  """

  import Ecto.Query, warn: false
  alias InBeauty.Repo

  alias InBeauty.Catalogue.{Product, Stock, ReservedStock}

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(InBeauty.PubSub, @topic)
  end

  def subscribe(product_id) do
    Phoenix.PubSub.subscribe(InBeauty.PubSub, @topic <> "#{product_id}")
  end

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Repo.all(Product)
  end

  @doc """
  Returns the list of products with filtering and pagination.

  ## Examples

      iex> list_products(%{gender: [male], })
      %%Scrivener.Page{entries: [%Produc{}, ...], page_number: _, page_size: _, total_entries: _, total_pages: _}

  """
  def list_products(params) when is_map(params) do
    #TODO stock in list stock function


    products_ids_from_filtered_stocks =
      Stock
      # |> filter_price(params)
      # |> filter_volumes(params)
      |> distinct(true)
      # |> select([s], s.product_id)
      # |> Repo.all
      # |> Enum.uniq()

    query =
      Product
      |> join(:left, [p], s in Stock, on: s.product_id == p.id)
      # |> join(:left, [p], s in ^products_ids_from_filtered_stocks)
      |> preload([p, s], [stocks: s])


    products_query =
      query
      |> filter_genders(params)
      |> filter_manufacturers(params)
      # |> filter_product_ids(products_ids_from_filtered_stocks)
      |> sort(params)
      # |> paginate(params)
      |> filter_price(params)
      |> filter_volumes(params)
      |> distinct([p, s], p.id)
      |> Repo.paginate(params)


    # total_count_query =
#       products_query
      # |> exclude(:limit)
      # |> exclude(:offset)
      # |> Repo.aggregate(:count, :name)
  end

  @doc """
  Returns the list of products with filtering and pagination.

  ## Examples

      iex> count_products(%{gender: [male], })
      %%Scrivener.Page{entries: [%Produc{}, ...], page_number: _, page_size: _, total_entries: _, total_pages: _}

  """
  def count_products(params) when is_map(params) do
    query =
      Product
      |> join(:left, [p], s in Stock, on: s.product_id == p.id)
      |> preload([p, s], [stocks: s])


    products_query =
      query
      |> filter_genders(params)
      |> filter_manufacturers(params)
      |> filter_price(params)
      |> filter_volumes(params)
      |> distinct([p, s], p.id)
      # |> Repo.paginate(params)
      |> Repo.aggregate(:count, :id)
  end

  defp filter_volumes(query, %{volumes: volumes})
    when volumes not in [[""], []]
    do
    volumes =
      volumes
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(&String.to_integer/1)

    where(query, [p, s], s.volume in ^volumes)
  end
  defp filter_volumes(query, _) do
    query
  end

  defp filter_price(query, %{price: [min, max]}) do
    min = String.to_integer(min)
    max = String.to_integer(max)

    where(query, [_p, s], s.price >= ^min and s.price <= ^max)
  end
  defp filter_price(query, _) do
    query
  end

  defp filter_genders(query, %{genders: genders})
    when genders not in [[""], []]
    do
    where(query,[q], q.gender in ^genders)
  end
  defp filter_genders(query, _) do
    query
  end

  defp filter_manufacturers(query, %{manufacturers: manufacturers})
    when manufacturers not in [[""], []]
    do
    where(query,[q], q.manufacturer in ^manufacturers)
  end
  defp filter_manufacturers(query, _) do
    query
  end

  # defp filter_product_ids(query, product_ids) do
  #   where(query, [s], s.id in ^product_ids)
  # end
  # defp filter_product_ids(query, []) do
  #   query
  # end

  # defp paginate(query, %{paginate: %{page: page, per_page: per_page}}) do
  #   query
  #   |> limit(^per_page)
  #   |> offset(^((page - 1) * per_page))
  # end
  # defp paginate(query, _) do
  #   query
  # end

  defp sort(query, %{sort: %{sort_by: sort_by, sort_order: sort_order}}) do
    order_by(query, [{^sort_order, ^sort_by}])
  end
  defp sort(query, _) do
    query
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id) do
    Product
    |> Repo.get!(id)
    |> Repo.preload([:carts_products, stocks: from(s in Stock, order_by: s.id)])
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}, after_save \\ &{:ok, &1}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
    |> after_save(after_save)
    |> notify_subscribers([:product, :created])
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs, after_save \\ &{:ok, &1}) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
    |> after_save(after_save)
    |> notify_subscribers([:product, :updated])
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    product
    |> Repo.delete()
    |> notify_subscribers([:product, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  defp after_save({:ok, product}, func) do
    {:ok, _product} = func.(product)
  end
  defp after_save(error, _func), do: error

  @doc """
  Returns the list of stocks.

  ## Examples

      iex> list_stocks()
      [%Stock{}, ...]

  """
  def list_stocks do
    Repo.all(Stock)
  end

  @doc """
  Gets a single stock.

  Raises `Ecto.NoResultsError` if the Stock does not exist.

  ## Examples

      iex> get_stock!(123)
      %Stock{}

      iex> get_stock!(456)
      ** (Ecto.NoResultsError)

  """
  def get_stock!(id), do: Repo.get!(Stock, id)

  @doc """
  Creates a stock.

  ## Examples

      iex> create_stock(%{field: value})
      {:ok, %Stock{}}

      iex> create_stock(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_stock(attrs \\ %{}) do
    %Stock{}
    |> Stock.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a stock.

  ## Examples

      iex> update_stock(stock, %{field: new_value})
      {:ok, %Stock{}}

      iex> update_stock(stock, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_stock(%Stock{} = stock, attrs) do
    stock
    |> Stock.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a stock.

  ## Examples

      iex> delete_stock(stock)
      {:ok, %Stock{}}

      iex> delete_stock(stock)
      {:error, %Ecto.Changeset{}}

  """
  def delete_stock(%Stock{} = stock) do
    Repo.delete(stock)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking stock changes.

  ## Examples

      iex> change_stock(stock)
      %Ecto.Changeset{data: %Stock{}}

  """
  def change_stock(stock, attrs \\ %{}) do
    Stock.changeset(stock, attrs)
  end

@doc """
  Returns the list of reserved_stocks.

  ## Examples

      iex> list_reserved_stocks()
      [%ReservedStock{}, ...]

  """
  def list_reserved_stocks do
    Repo.all(ReservedStock)
  end

  @doc """
  Gets a single reserved_stock.

  Raises `Ecto.NoResultsError` if the ReservedStock does not exist.

  ## Examples

      iex> get_reserved_stock!(123)
      %ReservedStock{}

      iex> get_reserved_stock!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reserved_stock!(id), do: Repo.get!(ReservedStock, id)

  @doc """
  Creates a reserved_stock.

  ## Examples

      iex> create_reserved_stock(%{field: value})
      {:ok, %ReservedStock{}}

      iex> create_reserved_stock(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reserved_stock(attrs \\ %{}) do
    %ReservedStock{}
    |> ReservedStock.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a reserved_stock.

  ## Examples

      iex> update_reserved_stock(reserved_stock, %{field: new_value})
      {:ok, %ReservedStock{}}

      iex> update_reserved_stock(reserved_stock, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reserved_stock(%ReservedStock{} = reserved_stock, attrs) do
    reserved_stock
    |> ReservedStock.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a reserved_stock.

  ## Examples

      iex> delete_reserved_stock(reserved_stock)
      {:ok, %ReservedStock{}}

      iex> delete_reserved_stock(reserved_stock)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reserved_stock(%ReservedStock{} = reserved_stock) do
    Repo.delete(reserved_stock)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reserved_stock changes.

  ## Examples

      iex> change_reserved_stock(reserved_stock)
      %Ecto.Changeset{data: %ReservedStock{}}

  """
  def change_reserved_stock(%ReservedStock{} = reserved_stock, attrs \\ %{}) do
    ReservedStock.changeset(reserved_stock, attrs)
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(InBeauty.PubSub, @topic, {__MODULE__, event, result})
    Phoenix.PubSub.broadcast(InBeauty.PubSub, @topic <> "#{result.id}", {__MODULE__, event, result})
    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
