defmodule InBeauty.Sdek.Sdek do
   @moduledoc """
    Module provides methods for communicating with Sdek api
  """
  alias InBeauty.Sdek.SdekClient

  require Logger

  # this method not 100%
  @spec get_city(String.t()) :: {:ok, map()} | {:error, any()}
  def get_city(nil), do: {:error, nil}
  def get_city(fias_id) do
    options = [params: %{fias_guid: fias_id}]

    case SdekClient.get("/location/cities", [], options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: nil}} ->
        {:error, :body_error}
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, List.first(body)}
      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
      error ->
        {:error, inspect(error)}
    end
  end

  #TODO should delete variants of {:error, something} if i don't use it
  @spec get_delivery_points(String.t() | nil) :: {:ok, any()} | {:error, any()}
  def get_delivery_points(nil), do: {:ok, []}
  def get_delivery_points(city_code) do
    options = [params: %{
        city_code: city_code,
        type: "PVZ"
    }]

    case SdekClient.get("/deliverypoints", [], options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: nil}} ->
        {:error, :body_error}
      {:ok, %HTTPoison.Response{status_code: 200, body: delivery_points}} ->
        {:ok, Enum.map(delivery_points, &(put_fields(&1)))}
      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}
      {:error, %HTTPoison.Error{reason: reason}} ->

        {:error, reason}
      error ->
        {:error, inspect(error)}
    end
  end

  # def create_map() do
  #   {:ok, tid} = Xlsxir.peek("./city_RUS.xlsx", 0, 40000)
  #   list = Xlsxir.get_list(tid)
  #   map =
  #   Enum.map(list, fn  l ->
  #     Map.new([{Enum.at(l, 14) || "nil", Enum.at(l, 0)}])
  #   end)
  #   |> Jason.encode!()
  #   File.write("/Users/ter/projects/new/in_beauty/a.txt", map)

  # end

  def calculate_delivery(nil), do: {:error, nil}
  def calculate_delivery(code) do
    headers = [{"Content-Type", "application/json"}]
      body = %{
        tariff_code: "136",
        from_location: %{
            code: 438
        },
        to_location: %{
            code: code
        },
        packages: [
          %{
              height: 15,
              length: 10,
              weight: 500,
              width: 10
          }
        ]
      }

      case SdekClient.post("/calculator/tariff", body, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: nil}} ->
          {:error, :body_error}
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, Map.take(body, [:period_min, :period_max, :total_sum])}
        {:ok, %HTTPoison.Response{body: body}} ->
          {:error, body}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, reason}
        error ->
          {:error, inspect(error)}
      end
  end

  def calculate_deliveries(nil), do: {:error, nil}
  def calculate_deliveries(code) do
    headers = [{"Content-Type", "application/json"}]
      body = %{
        from_location: %{
            code: 438
        },
        to_location: %{
            code: code
        },
        packages: [
          %{
              height: 15,
              length: 10,
              weight: 500,
              width: 10
          }
        ]
      }

      case SdekClient.post("/calculator/tarifflist", body, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: nil}} ->
          {:error, :body_error}
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          body =
            body
            |> Map.get(:tariff_codes)
            |> Enum.filter(fn tariff ->
              if tariff.tariff_code in [136, 137] do
                Map.take(tariff, [:period_min, :period_max, :delivery_sum, :tariff_code])
              end
            end)
            |> Map.new(fn tariff -> {tariff.tariff_code, tariff} end)
          {:ok, body}
        {:ok, %HTTPoison.Response{body: body}} ->
          {:error, body}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, reason}
        error ->
          {:error, inspect(error)}
      end
  end

  def put_fields(%{location: location} = delivery_point) do
    params =
      location
      |> Map.take([:city_code, :city, :latitude, :longitude, :address, :address_full])
      |> Map.merge(delivery_point)

    struct(%InBeauty.Deliveries.DeliveryPoint{}, params)
  end
  # @spec create_cds_order(Order.t(), map()) :: map()
  # def create_cds_order(order, args) do
  #   products_weight = get_prducts_weight(order.products)

  #   headers = [
  #     "Content-Type": "application/json",
  #     "Accept-Encoding": "gzip, deflate, br"
  #   ]

  #   body = %{
  #     comment: "#{args.delivery_comment}",
  #     shipment_point: "RND21",
  #     packages: [%{
  #       number: String.slice(order.id, 0, 29),
  #       items: get_products(order.products),
  #       weight: products_weight
  #     }],
  #     recipient: %{
  #       name: "#{args.name} #{args.surname} #{args.patronymic}",
  #       phones: [%{
  #         number: "+#{args.phone_number}"
  #       }]
  #     },
  #     sender: %{
  #       name: "CoffeeBright"
  #     },
  #     tariff_code: get_tariff_code(products_weight, args)
  #   }
  #   |> Map.merge(extract_delivery_method(args))
  #   |> Jason.encode!

  #   with {:ok, response} <- CdsRequest.post("/orders", body, headers),
  #        202 <- response.status_code,
  #        {:validation_errors, []} <- Payments.find_validation_errors(response.body.requests)
  #   do
  #       {:ok, response.body}
  #   else
  #     {:validation_errors, errors} ->
  #       {:validation_errors, errors}
  #     _ ->
  #       {:error, nil}
  #   end
  # end

  # def extract_delivery_method(%{delivery_method: :CDS_PICKUP, delivery_point: point}), do: %{delivery_point: "#{point}"}
  # def extract_delivery_method(args) do
  #   %{
  #     to_location: %{
  #     code: "438",
  #     fias_guid: "",
  #     postal_code: "",
  #     longitude: "",
  #     latitude: "",
  #     country_code: "",
  #     region: "",
  #     sub_region: "",
  #     city: "–†–æ—Å—Ç–æ–≤-–Ω–∞-–î–æ–Ω—É",
  #     kladr_code: "",
  #     address: "—É–ª. #{args.street}, –∫–≤. #{args.flat}"
  #     }
  #   }
  # end

  # @spec trim_weight(String.t()) :: number()
  # def trim_weight(string_number) do
  #   string_number
  #   |> String.replace(~r/\D/, "")
  #   |> String.to_integer()
  # end

  # @spec get_prducts_weight(list(), number()) :: number()
  # def get_prducts_weight(products, acc \\ 0)
  # def get_prducts_weight([], acc), do: acc
  # def get_prducts_weight([product | tail], acc) do
  #   weight = trim_weight(product.attributes.weight)
  #   get_prducts_weight(tail, acc + weight)
  # end

  # @spec get_products(list(), list()) :: list()
  # def get_products(products, acc \\ [])
  # def get_products([], acc), do: acc
  # def get_products([product | tail], acc) do
  #   weight = trim_weight(product.attributes.weight)

  #   order_product = %{
  #     ware_key: product.id,
  #     payment: %{
  #       value: 0
  #     },
  #     name: product.name,
  #     cost: product.price,
  #     amount: product.order_quantity,
  #     weight: weight
  #   }

  #   get_products(tail, [order_product | acc])
  # end

  @spec get_tariff_code(number(), map()) :: number()
  def get_tariff_code(products_weight, %{delivery_method: :sdek_pickup}) when products_weight < 30_000, do: 136
  def get_tariff_code(products_weight, %{delivery_method: :sdek_pickup}) when products_weight < 50_000, do: 234
  def get_tariff_code(products_weight, %{delivery_method: :sdek_courier}) when products_weight < 30_000, do: 137
  def get_tariff_code(products_weight, %{delivery_method: :sdek_courier}) when products_weight < 50_000, do: 233

end
