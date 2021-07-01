defmodule InBeauty.Search.DaData do
  def get_statistics() do
    case InBeauty.Search.DaData.DaDataAccountClient.get("/stat/daily", [], []) do
      {:ok, %HTTPoison.Response{status_code: 200, body: %{services: services}}} ->
        {:ok,
          services
          |> Map.values()
          |> Enum.sum()
        }
      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
      error ->
        {:error, inspect(error)}
    end
  end

  def search(body) do
    #  %{query: "Красное", from_bound: %{ value: "city" }, to_bound: %{ value: "settlement" }, locations: [%{ region_fias_id: "c99e7924-0428-4107-a302-4fd7c0cca3ff" }], restrict_value: true}
    case InBeauty.Search.DaData.DaDataClient.post("/suggest/address", body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: suggestions}} ->
        {:ok, Enum.map(suggestions, &(put_fields(&1)))}
      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
      error ->
        {:error, inspect(error)}
    end
  end

  def search_by_id(fias_id_or_kladr_id) do
    body = %{query: fias_id_or_kladr_id}

    case InBeauty.Search.DaData.DaDataClient.post("/findById/address", body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: []}} ->
        {:error, nil}
      {:ok, %HTTPoison.Response{status_code: 200, body: suggestions}} ->
        {:ok,
          suggestions
          |> List.first()
          |> put_fields()
        }
      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
      error ->
        {:error, inspect(error)}
    end
  end

  @spec get_delivery_city_codes(String.t()) :: {:ok, Integer} | {:error, any()}
  def get_delivery_city_codes(kladr_id) do
    body = %{query: kladr_id}

    case InBeauty.Search.DaData.DaDataClient.post("/findById/delivery", body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: [%{data: data}]}} ->
        {:ok,
          data
          |> Map.get(:cdek_id)
          |> String.to_integer()
        }

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
      error ->
        {:error, inspect(error)}
    end
  end

  def put_fields(dadata_address) do
    longitude = if dadata_address.data.geo_lon, do: String.to_float(dadata_address.data.geo_lon), else: nil
    latitude = if dadata_address.data.geo_lat, do: String.to_float(dadata_address.data.geo_lat), else: nil
    params =
      dadata_address
      |> Map.get(:data)
      |> Map.put(:longitude, longitude)
      |> Map.put(:latitude, latitude)

    struct(%InBeauty.Deliveries.Delivery{}, params)
  end
end
