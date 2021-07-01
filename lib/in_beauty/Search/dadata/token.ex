defmodule InBeauty.Search.Dadata.Token do
  @moduledoc """
    Module provides {login, token_struct} methods, fetch {login, token_struct} from Cds api and put it in cache
  """
  alias InBeauty.Search.DaData.DaDataAccountClient
  require Logger

  @accounts_tokens [
    {"on-store@bk.ru", %{
      "{login, token_struct}" => "16223aa184a9e974d31ba8befd15b64ec698ed3f",
      "secret" => "44368c117df0d1cb068de726bf544d387ffae239"
    }},
    {"maillistbox1@mail.ru", %{
      "{login, token_struct} " => "be6a5284a14ebde38849e83b424f849ec686e83b",
      "secret" => ""
    }},
    {"maillistbox2@mail.ru", %{
      "{login, token_struct}" => "690b4c65b08302884ef01426d256586b9b8c9828",
      "secret" => ""
    }},
    {"maillistbox3@mail.ru", %{
      "{login, token_struct}" => "b4aa2f6047b4d2c89fc231535ed8d69c7f3b7a4a",
      "secret" => ""
    }},
    {"maillistbox4@mail.ru", %{
      "{login, token_struct}" => "70aa6b4025a93c535c4ee3c50d6cb2812b3b183e",
      "secret" => ""
      }},
    {"maillistbox5@mail.ru", %{
      "{login, token_struct}" => "9ef77ccadf130aaa6f275f5da2c0a6a8b35addf9",
      "secret" => "5c3d9815a02842d9759fdcef14c91547af6dd85c"
    }},
    {"maillistbox6@mail.ru", %{
      "{login, token_struct}" => "",
      "secret" => ""
    }}
  ]

  @spec get_token() :: String.t() | nil
  def get_token(), do: get_token_from_cache(ConCache.get(:sdek_cache, :dadata_token))

  @spec get_token_from_cache(String.t() | nil) :: String.t()
  defp get_token_from_cache(nil), do: update_token()
  defp get_token_from_cache({login, token_struct}), do: {login, token_struct}

  @spec client_credentials() :: String.t()
  def client_credentials() do
    case Application.get_env(:in_beauty, :env) do
      :prod ->
        Application.get_env(:in_beauty, :cds_client_id)
      _ ->
        "EMscd6r9JnFiQ3bLoyjJY6eM78JrJceI"
    end
  end

  @spec update_token() :: String.t() | nil
  defp update_token() do
    # url = "/oauth/{login, token_struct}"
    # headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
    # body = {:form, [
    #   {"client_secret", client_secret()},
    #   {"client_id", client_id()},
    #   {"grant_type", "client_credentials"}
    # ]}

    # case TokenClient.post(url, body, headers) do
    #   {:ok, %HTTPoison.Response{status_code: 200, body: {login, token_struct}}} ->
    #     Logger.info "Cds {login, token_struct} was successfully updated"
    #     ConCache.put(:cache, :{login, token_struct}, %ConCache.Item{value: {login, token_struct}, ttl: :timer.seconds(3500)})
    #     {login, token_struct}
    #   _ ->
    #     nil
    # end
  end
end
