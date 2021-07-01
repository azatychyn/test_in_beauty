defmodule InBeauty.Search.Kladr do
  def search(params \\ %{}) do
    default_params = %{"query" => "", "contentType" => "city", "limit" => 10, "withParents" => true}

    options = [
      params: Map.merge(default_params, params)
    ]

    case InBeauty.Search.KladrClient.get("", [], options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: %{result: suggestions}}} ->
        {:ok, Enum.map(suggestions, &(put_fields(&1)))}
      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
      error -> {:error, inspect(error)}
    end
  end

  def put_fields(kladr_address) do
    kladr_address
    |> List.wrap()
    |> Enum.concat(kladr_address.parents)
    |> Enum.reduce(%InBeauty.Deliveries.Delivery{}, fn address, acc ->
      prefix = content_type(address.contentType)

      acc
      |> put_id(address.id, prefix)
      |> put_name(address.name, prefix)
      |> put_guid(address.guid, prefix)
      |> put_type(address.typeShort, prefix)
      |> put_type_full(address.type, prefix)
    end)
  end

  def put_id(address_struct, id, prefix) do
    field = "#{prefix}_kladr_id"
    %{address_struct | "#{field}": id}
  end

  def put_name(address_struct, name, prefix) do
    %{address_struct | "#{prefix}": name}
  end

  def put_guid(address_struct, gid, prefix) do
    field = "#{prefix}_fias_id"
    %{address_struct | "#{field}": gid}
  end

  def put_type(address_struct, type, prefix) do
    field = "#{prefix}_type"
    %{address_struct | "#{field}": type}
  end

  def put_type_full(address_struct, type, prefix) do
    field = "#{prefix}_type_full"
    %{address_struct | "#{field}": type}
  end

  def content_type("district"), do: "area"
  def content_type("building"), do: "house"
  def content_type("cityOwner"), do: "city"

  def content_type(type), do: type
end
