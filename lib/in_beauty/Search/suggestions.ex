defmodule InBeauty.Search.Suggestions do
  alias InBeauty.Search.Kladr
  alias InBeauty.Search.DaData

  def find(params) do
    case DaData.search(params) do
      {:ok, suggestions} ->
        suggestions

      {:error, :nxdomain} ->
        {:error, :nxdomain}

      _ ->
        search_by_kladr(params.query)
    end
  end

  def search_by_kladr(query) do
    case Kladr.search(%{"query" => query}) do
      {:ok, suggestions} ->
        suggestions
      _ ->
        []
    end
  end

  @spec search_city_code(String.t(), String.t()) :: nil | Integer
  def search_city_code(fias_id, kladr_id) do
    fias_id
    |> InBeauty.Sdek.Sdek.get_city()
    |> maybe_search_by_dadata_delivery(kladr_id)
    |> case do
      {:ok, code} ->
        code
      _ ->
        nil
    end
  end

  @spec maybe_search_by_dadata_delivery({:ok, Integer} | {:ok, nil}, String.t()) ::
          {:ok, Integer} | {:ok, nil} | {:error, any()}
  def maybe_search_by_dadata_delivery({:ok, %{code: code}}, _), do: {:ok, code}
  def maybe_search_by_dadata_delivery(_, kladr_id), do: InBeauty.Search.DaData.get_delivery_city_codes(kladr_id)

  @spec get_geo_coordinates(String.t()) :: {float(), float()} | {nil, nil}
  def get_geo_coordinates(fias_id) do
    fias_id
    |> InBeauty.Sdek.Sdek.get_city()
    |> case do
      {:ok, map} ->
        {map.latitude, map.longitude}
      _ ->
        {nil, nil}
    end
  end
end
