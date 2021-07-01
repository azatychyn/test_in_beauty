# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     InBeauty.Repo.insert!(%InBeauty.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Enum.map(1..1000, fn i ->
  InBeauty.Catalogue.create_product(%{
    description: "some desc#{i}",
    name: "some_name#{i}",
    gender: Enum.random(["men", "women", "unisex"]),
    manufacturer: "some manufacturer",
    stocks: [
      %{
        price: Enum.random(1..1000),
        volume: Enum.random([30, 30, 40, 50, 100, 200]),
        quantity: 100,
        image_path: "https://picsum.photos/200/200",
        weight: 100
      }
    ]
  })
end)
