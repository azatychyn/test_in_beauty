defmodule InBeauty.Relations do
  @moduledoc """
  The Relations context.
  """

  import Ecto.Query, warn: false

  alias InBeauty.Repo
  alias InBeauty.Relations.StockCart
  alias InBeauty.Relations.StockOrder
  alias InBeauty.Relations.FavoriteProduct
  alias InBeauty.Payments.Cart

  @spec list_stock_carts() :: [StockCart.t()] | []
  def list_stock_carts, do: Repo.all(StockCart)

  @spec get_stock_cart!(Sting.t()) :: StockCart.t() | Ecto.NoResultsError
  def get_stock_cart!(id), do: Repo.get!(StockCart, id)

  @spec get_stock_cart_by(Keyword.t() | map()) :: StockCart.t() | nil
  def get_stock_cart_by(options), do: Repo.get_by(StockCart, options)

  @spec get_stock_cart_by!(Keyword.t() | map()) :: StockCart.t() | Ecto.NoResultsError
  def get_stock_cart_by!(options), do: Repo.get_by!(StockCart, options)

  @spec create_stock_cart(map()) :: {:ok, StockCart.t()} | {:error, Ecto.Changeset.t()}
  def create_stock_cart(attrs \\ %{}) do
    %StockCart{}
    |> StockCart.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_stock_cart(StockCart.t(), map()) :: {:ok, StockCart.t()} | {:error, Ecto.Changeset.t()}
  def update_stock_cart(%StockCart{} = stock_cart, attrs) do
    stock_cart
    |> StockCart.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_stock_cart(StockCart.t()) :: {:ok, StockCart.t()} | {:error, Ecto.Changeset.t()}
  def delete_stock_cart(stock_cart), do: Repo.delete(stock_cart)

  @spec change_stock_cart(StockCart.t()) :: Ecto.Changeset.t()
  def change_stock_cart(%StockCart{} = stock_cart), do: StockCart.changeset(stock_cart, %{})

  def verify_stocks_carts(stocks_carts, acc \\ [])
  def verify_stocks_carts([], acc), do: acc
  def verify_stocks_carts([stock_cart | tail], acc) do
    stock = stock_cart.stock

    case stock.quantity >= stock_cart.quantity do
      true ->
        verify_stocks_carts(tail, acc)
      false ->
        #TODO may be think another way to check if it updates
        update_stock_cart(stock_cart, %{quantity: stock.quantity})
        changeset =
          stock_cart
          |> change_stock_cart()
          |> Ecto.Changeset.add_error(:quantity, "There are only #{stock.quantity} in stock")
        [changeset | acc]
    end
  end

  #
  # StockOrder
  #

  @spec list_stock_orders() :: [StockOrder.t()] | []
  def list_stock_orders, do: Repo.all(StockOrder)

  @spec get_stock_order!(Sting.t()) :: StockOrder.t() | Ecto.NoResultsError
  def get_stock_order!(id), do: Repo.get!(StockOrder, id)

  @spec get_stock_order_by(Keyword.t()) :: StockOrder.t() | Ecto.NoResultsError
  def get_stock_order_by(options), do: Repo.get_by(StockOrder, options)


  @spec create_stock_order(map()) :: {:ok, StockOrder.t()} | {:error, Ecto.Changeset.t()}
  def create_stock_order(attrs \\ %{}) do
    %StockOrder{}
    |> StockOrder.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_stock_order(StockOrder.t(), map()) :: {:ok, StockOrder.t()} | {:error, Ecto.Changeset.t()}
  def update_stock_order(%StockOrder{} = stock_order, attrs) do
    stock_order
    |> StockOrder.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_stock_order(StockOrder.t()) :: {:ok, StockOrder.t()} | {:error, Ecto.Changeset.t()}
  def delete_stock_order(stock_order), do: Repo.delete(stock_order)

  @spec change_stock_order(StockOrder.t()) :: Ecto.Changeset.t()
  def change_stock_order(%StockOrder{} = stock_order), do: StockOrder.changeset(stock_order, %{})

  #
  # FavoriteProduct
  #

  @spec list_favorite_products() :: [FavoriteProduct.t()] | []
  def list_favorite_products, do: Repo.all(FavoriteProduct)

  @spec get_favorite_product_by(Keyword.t() | map()) :: FavoriteProduct.t() | nil
  def get_favorite_product_by(options), do: Repo.get_by(FavoriteProduct, options)

  @spec get_favorite_product_by!(Keyword.t() | map()) :: FavoriteProduct.t() | Ecto.NoResultsError
  def get_favorite_product_by!(options), do: Repo.get_by!(FavoriteProduct, options)

  @spec create_favorite_product(map()) :: {:ok, FavoriteProduct.t()} | {:error, Ecto.Changeset.t()}
  def create_favorite_product(attrs \\ %{}) do
    %FavoriteProduct{}
    |> FavoriteProduct.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_favorite_product(FavoriteProduct.t(), map()) :: {:ok, FavoriteProduct.t()} | {:error, Ecto.Changeset.t()}
  def update_favorite_product(%FavoriteProduct{} = favorite_product, attrs) do
    favorite_product
    |> FavoriteProduct.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_favorite_product(FavoriteProduct.t()) :: {:ok, FavoriteProduct.t()} | {:error, Ecto.Changeset.t()}
  def delete_favorite_product(favorite_product), do: Repo.delete(favorite_product)

  @spec change_favorite_product(FavoriteProduct.t()) :: Ecto.Changeset.t()
  def change_favorite_product(%FavoriteProduct{} = favorite_product), do: FavoriteProduct.changeset(favorite_product, %{})
end
