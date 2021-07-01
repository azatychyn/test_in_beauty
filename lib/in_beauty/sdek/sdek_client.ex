defmodule InBeauty.Sdek.SdekClient do
  @moduledoc """
    Module provides client for requesting Sdek api
  """

  use HTTPoison.Base

  alias InBeauty.Sdek.Token

  require Logger

  @endpoint "https://api.cdek.ru/v2"
  @test_endpoint "https://api.edu.cdek.ru/v2"

  def process_request_url(url) do
    IO.inspect("i make request to sdek -- #{url}")
    case Application.get_env(:in_beauty, :env) do
      :prod ->
        @endpoint <> url
      _ -> @test_endpoint <> url
    end
  end

  def process_request_headers(headers) do
    token = Token.get_token()

    headers ++ [
      "Authorization": "Bearer #{token}"
    ]
  end

  def process_request_body(body) do
    Jason.encode!(body)
  end

  def process_response_body(body) do
    #TODO what whould be if it couse an error ->
    case Jason.decode(body, keys: :atoms) do
      {:ok, body} ->
       body
      _ ->
        nil
    end
  end
end
