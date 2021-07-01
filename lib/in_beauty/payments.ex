defmodule InBeauty.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false
  alias InBeauty.Repo

  alias InBeauty.Payments.Cart
  alias InBeauty.Repo
  alias InBeauty.Relations.StockCart
  alias InBeauty.Relations.StockOrder

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(InBeauty.PubSub, @topic)
  end

  def subscribe(cart_id) do
    Phoenix.PubSub.subscribe(InBeauty.PubSub, @topic <> "#{cart_id}")
  end

  @doc """
  Returns the list of carts.

  ## Examples

      iex> list_carts()
      [%Cart{}, ...]

  """
  def list_carts do
    Repo.all(Cart)
  end

  @doc """
  Returns the list of carts with filtering and pagination.

  ## Examples

      iex> list_carts(%{role: ["admin"], })
      %%Scrivener.Page{entries: [%Cart{}, ...], page_number: _, page_size: _, total_entries: _, total_pages: _}

  """
  def list_carts(params) when is_map(params) do
      Cart
      |> filter_roles(params)
      |> sort(params)
      |> Repo.paginate(params)
  end

  @doc """
  Returns the list of products with filtering and pagination.

  ## Examples

      iex> count_products(%{gender: [male], })
      %%Scrivener.Page{entries: [%Produc{}, ...], page_number: _, page_size: _, total_entries: _, total_pages: _}

  """
  def count_carts(params) when is_map(params) do
      Cart
      |> filter_roles(params)
      |> Repo.aggregate(:count, :id)
  end

  defp filter_roles(query, %{roles: ["user", ""]})
  do
    where(query,[q], q.anon == false)
  end
  defp filter_roles(query, %{roles: ["anon", ""]})
  do
    where(query,[q], q.anon == true)
  end
  defp filter_roles(query, _) do
    query
  end

  defp sort(query, %{sort: %{sort_by: sort_by, sort_order: sort_order}}) do
    order_by(query, [{^sort_order, ^sort_by}])
  end
  defp sort(query, _) do
    query
  end

  @doc """
  Gets a single cart by params.

  ## Examples

      iex> get_cart([field: value])
      %Cart{}

      iex> get_cart([field: bad_value])
      nil

  """
  def get_cart_by(params), do: Repo.get_by(Cart, params)

  @doc """
  Gets a single cart.

  Raises `Ecto.NoResultsError` if the Cart does not exist.

  ## Examples

      iex> get_cart!(123)
      %Cart{}

      iex> get_cart!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cart!(id), do: Repo.get!(Cart, id)

  @doc """
  Creates a cart.

  ## Examples

      iex> create_cart(%{field: value})
      {:ok, %Cart{}}

      iex> create_cart(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cart(attrs \\ %{}) do
    %Cart{}
    |> Cart.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:cart, :created])
  end

  @doc """
  Updates a cart.

  ## Examples

      iex> update_cart(cart, %{field: new_value})
      {:ok, %Cart{}}

      iex> update_cart(cart, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cart(%Cart{} = cart, attrs) do
    cart
    |> Cart.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:cart, :updated])
  end

  @doc """
  Deletes a cart.

  ## Examples

      iex> delete_cart(cart)
      {:ok, %Cart{}}

      iex> delete_cart(cart)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cart(%Cart{} = cart) do
    Repo.delete(cart)
    |> notify_subscribers([:cart, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cart changes.

  ## Examples

      iex> change_cart(cart)
      %Ecto.Changeset{data: %Cart{}}

  """
  def change_cart(%Cart{} = cart, attrs \\ %{}) do
    Cart.changeset(cart, attrs)
  end

  def get_cart_by_user_id(user_id) do
     Repo.get_by(Cart, user_id: user_id)
  end

  def add_cart_attrs(cart), do: add_cart_attrs(cart.stocks_carts, cart, {0,0})
  def add_cart_attrs(stocks_carts, cart, acc)
  def add_cart_attrs([], cart, {product_count, total_price}) do
    %Cart{cart | total_price: total_price, product_count: product_count}
  end
  def add_cart_attrs([stock_cart | tail], cart, {cart_count, total_price}) do
    acc = {stock_cart.quantity + cart_count, stock_cart.stock.price * stock_cart.quantity + total_price}
    add_cart_attrs(tail, cart, acc)
  end


  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(InBeauty.PubSub, @topic, {__MODULE__, event, result})
    Phoenix.PubSub.broadcast(InBeauty.PubSub, @topic <> "#{result.id}", {__MODULE__, event, result})
    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}

  alias InBeauty.Payments.Order
  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders()
      [%Order{}, ...]

  """
  def list_orders do
    Repo.all(Order)
  end

  @doc """
  Returns the list of orders with filtering and pagination.

  ## Examples

      iex> list_orders(%{role: ["admin"], })
      %%Scrivener.Page{entries: [%Order{}, ...], page_number: _, page_size: _, total_entries: _, total_pages: _}

  """
  def list_orders(params) when is_map(params) do
      Order
      |> filter_price(params)
      |> sort(params)
      |> Repo.paginate(params)
  end

  @doc """
  Returns the list of products with filtering and pagination.

  ## Examples

      iex> count_products(%{gender: [male], })
      %%Scrivener.Page{entries: [%Produc{}, ...], page_number: _, page_size: _, total_entries: _, total_pages: _}

  """
  def count_orders(params) when is_map(params) do
      Order
      |> filter_price(params)
      |> Repo.aggregate(:count, :id)
  end

  defp filter_price(query, %{price: [min, max]}) do
    min = String.to_integer(min)
    max = String.to_integer(max)

    where(query, [q], q.total_price >= ^min and q.total_price <= ^max)
  end
  defp filter_price(query, _) do
    query
  end

  defp sort(query, %{sort: %{sort_by: sort_by, sort_order: sort_order}}) do
    order_by(query, [{^sort_order, ^sort_by}])
  end
  defp sort(query, _) do
    query
  end

  @doc """
  Gets a single order by params.

  ## Examples

      iex> get_order([field: value])
      %Order{}

      iex> get_order([field: bad_value])
      nil

  """
  def get_order_by(params), do: Repo.get_by(Order, params)

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(id), do: Repo.get!(Order, id)

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(order, attrs \\ %{}) do
    order
    |> Order.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:order, :created])
  end

  @doc """
  Updates a order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:order, :updated])
  end

  @doc """
  Deletes a order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
    |> notify_subscribers([:order, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{data: %Order{}}

  """
  def change_order(order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end

  def add_order_attrs(stocks_orders, order, acc \\ 0)
  def add_order_attrs([], order, total_price) do
    %Order{order | total_price: total_price}
  end
  def add_order_attrs([stock_order | tail], order, total_price) do
    acc = stock_order.stock.price * stock_order.quantity + total_price
    add_order_attrs(tail, order, acc)
  end
end
