defmodule InBeauty.Search.KladrClient do
  use HTTPoison.Base

  @token "dbE2bFtkY4Bf3fYnKz2K7F7i5tey3DRY"
  @endpoint "https://kladr-api.ru/api.php"

  def process_url(url) do
    @endpoint <> url
  end

  def process_response_body(body) do
    case Jason.decode(body, keys: :atoms) do
      {:ok, body} ->
        result = Enum.filter(body.result, &(&1.id != "Free"))
        put_in(body, [:result], result)
      _ ->
        :error
    end
  end
  def process_request_params(params) do
    IO.inspect("i make request to kladr")
    params
    |> put_in(["token"], @token)
    |> put_in(["withParent"], true)
  end
end
