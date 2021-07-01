defmodule InBeauty.Search.DaData.DaDataClient do
  use HTTPoison.Base

  @accounts_tokens %{
    "on-store@bk.ru" => %{
      "token" => "16223aa184a9e974d31ba8befd15b64ec698ed3f",
      "secret" => "44368c117df0d1cb068de726bf544d387ffae239"
    },
    "maillistbox1@mail.ru" => %{
      "token " => "be6a5284a14ebde38849e83b424f849ec686e83b",
      "secret" => ""
    },
    "maillistbox2@mail.ru" => "690b4c65b08302884ef01426d256586b9b8c9828",
    "maillistbox3@mail.ru" => "b4aa2f6047b4d2c89fc231535ed8d69c7f3b7a4a",
    "maillistbox4@mail.ru" => "70aa6b4025a93c535c4ee3c50d6cb2812b3b183e",
    "maillistbox5@mail.ru" => %{
      "token" => "9ef77ccadf130aaa6f275f5da2c0a6a8b35addf9",
      "secret" => "5c3d9815a02842d9759fdcef14c91547af6dd85c"
    },
    "maillistbox6@mail.ru" => %{
      "token" => "",
      "secret" => ""
    }
  }
  @token "16223aa184a9e974d31ba8befd15b64ec698ed3f"
  @endpoint "https://suggestions.dadata.ru/suggestions/api/4_1/rs"
  @test_endpoint "https://suggestions.dadata.ru:443/suggestions/api/4_1/rs"

  def process_url(url) do
    IO.inspect("i make request to dadata -- #{url}")
    @test_endpoint <> url
  end

  def process_request_headers(headers) do
    [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"Authorization", "Token #{@token}"}
    ] ++ headers
  end

  def process_request_body(body) do
    Jason.encode!(body)
  end

  def process_response_body(body) do
    #TODO check if any error have the same struct
    case Jason.decode(body, keys: :atoms) do
      {:ok, body} ->
        Map.get(body, :suggestions)
      _ ->
        :error
    end
  end
end
