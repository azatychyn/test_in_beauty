defmodule InBeauty.CatalogueTest do
  use InBeauty.DataCase

  import InBeauty.ProductFixtures
  import InBeauty.StockFixtures

  alias InBeauty.Repo
  alias InBeauty.Catalogue
  alias InBeauty.Catalogue.{Product, Review, Stock}

  describe "products" do
    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Repo.preload(Catalogue.list_products(), [:reviews, :stocks]) == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Repo.preload(Catalogue.get_product!(product.id), [:reviews, :stocks]) == product
    end

    test "create_product/1 with valid data creates a product" do
      assert {:ok, %Product{} = product} = Catalogue.create_product(valid_product_attrs())
      assert product.description == valid_product_attrs().description
      assert product.id == valid_product_attrs().id
      assert product.gender == valid_product_attrs().gender
      assert product.name == valid_product_attrs().name
      assert product.manufacturer == valid_product_attrs().manufacturer
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalogue.create_product(invalid_product_attrs())
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      assert {:ok, %Product{} = product} = Catalogue.update_product(product, update_product_attrs())
      assert product.description == update_product_attrs().description
      assert product.id == update_product_attrs().id
      assert product.gender == update_product_attrs().gender
      assert product.name == update_product_attrs().name
      assert product.manufacturer == update_product_attrs().manufacturer
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalogue.update_product(product, invalid_product_attrs())
      assert product ==  Repo.preload(Catalogue.get_product!(product.id), [:reviews, :stocks])
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Catalogue.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Catalogue.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Catalogue.change_product(product)
    end
  end

  # describe "reviews" do
  #   alias InBeauty.Catalogue.Review

  #   valid_attrs() %{"": "some ", accepted: true, content: "some content", email: "some email", id: "some id", name: "some name", product_id: "some product_id", rating: 42}
  #   update_attrs() %{"": "some updated ", accepted: false, content: "some updated content", email: "some updated email", id: "some updated id", name: "some updated name", product_id: "some updated product_id", rating: 43}
  #   invalid_attrs() %{"": nil, accepted: nil, content: nil, email: nil, id: nil, name: nil, product_id: nil, rating: nil}

  #   def review_fixture(attrs \\ %{}) do
  #     {:ok, review} =
  #       attrs
  #       |> Enum.into(valid_attrs())
  #       |> Catalogue.create_review()

  #     review
  #   end

  #   test "list_reviews/0 returns all reviews" do
  #     review = review_fixture()
  #     assert Catalogue.list_reviews() == [review]
  #   end

  #   test "get_review!/1 returns the review with given id" do
  #     review = review_fixture()
  #     assert Catalogue.get_review!(review.id) == review
  #   end

  #   test "create_review/1 with valid data creates a review" do
  #     assert {:ok, %Review{} = review} = Catalogue.create_review(valid_attrs())
  #     assert review. == "some "
  #     assert review.accepted == true
  #     assert review.content == "some content"
  #     assert review.email == "some email"
  #     assert review.id == "some id"
  #     assert review.name == "some name"
  #     assert review.product_id == "some product_id"
  #     assert review.rating == 42
  #   end

  #   test "create_review/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Catalogue.create_review(invalid_attrs())
  #   end

  #   test "update_review/2 with valid data updates the review" do
  #     review = review_fixture()
  #     assert {:ok, %Review{} = review} = Catalogue.update_review(review, update_attrs())
  #     assert review. == "some updated "
  #     assert review.accepted == false
  #     assert review.content == "some updated content"
  #     assert review.email == "some updated email"
  #     assert review.id == "some updated id"
  #     assert review.name == "some updated name"
  #     assert review.product_id == "some updated product_id"
  #     assert review.rating == 43
  #   end

  #   test "update_review/2 with invalid data returns error changeset" do
  #     review = review_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Catalogue.update_review(review, invalid_attrs())
  #     assert review == Catalogue.get_review!(review.id)
  #   end

  #   test "delete_review/1 deletes the review" do
  #     review = review_fixture()
  #     assert {:ok, %Review{}} = Catalogue.delete_review(review)
  #     assert_raise Ecto.NoResultsError, fn -> Catalogue.get_review!(review.id) end
  #   end

  #   test "change_review/1 returns a review changeset" do
  #     review = review_fixture()
  #     assert %Ecto.Changeset{} = Catalogue.change_review(review)
  #   end
  # end

  describe "stocks" do
    setup do
      {:ok, product: InBeauty.ProductFixtures.product_fixture()}
    end

    test "list_stocks/0 returns all stocks", context do
      stock = stock_fixture(%{product_id: context.product.id})
      assert Catalogue.list_stocks() == [stock]
    end

    test "get_stock!/1 returns the stock with given id", context do
      stock = stock_fixture(%{product_id: context.product.id})
      assert Catalogue.get_stock!(stock.id) == stock
    end

    test "create_stock/1 with valid data creates a stock", context do
      stock_attrs = Enum.into( %{product_id: context.product.id}, valid_stock_attrs())
      assert {:ok, %Stock{} = stock} = Catalogue.create_stock(stock_attrs)
      assert stock.id == valid_stock_attrs().id
      assert stock.image_path == valid_stock_attrs().image_path
      assert stock.price == valid_stock_attrs().price
      assert stock.product_id == context.product.id
      assert stock.quantity == valid_stock_attrs().quantity
      assert stock.volume == valid_stock_attrs().volume
    end

    test "create_stock/1 with invalid data returns error changeset", context do
      assert {:error, %Ecto.Changeset{}} = Catalogue.create_stock(invalid_stock_attrs())
    end

    test "update_stock/2 with valid data updates the stock", context do
      stock = stock_fixture(%{product_id: context.product.id})
      assert {:ok, %Stock{} = stock} = Catalogue.update_stock(stock, update_stock_attrs())
      assert stock.id == update_stock_attrs().id
      assert stock.image_path == update_stock_attrs().image_path
      assert stock.price == update_stock_attrs().price
      assert stock.product_id == context.product.id
      assert stock.quantity == update_stock_attrs().quantity
      assert stock.volume == update_stock_attrs().volume
    end

    test "update_stock/2 with invalid data returns error changeset", context do
      stock = stock_fixture(%{product_id: context.product.id})
      assert {:error, %Ecto.Changeset{}} = Catalogue.update_stock(stock, invalid_stock_attrs())
      assert stock ==  Catalogue.get_stock!(stock.id)
    end

    test "delete_stock/1 deletes the stock", context do
      stock = stock_fixture(%{product_id: context.product.id})
      assert {:ok, %Stock{}} = Catalogue.delete_stock(stock)
      assert_raise Ecto.NoResultsError, fn -> Catalogue.get_stock!(stock.id) end
    end

    test "change_stock/1 returns a stock changeset", context do
      stock = stock_fixture(%{product_id: context.product.id})
      assert %Ecto.Changeset{} = Catalogue.change_stock(stock)
    end
  end
end
