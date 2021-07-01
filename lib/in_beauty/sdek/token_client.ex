defmodule InBeauty.Sdek.TokenClient do
  @moduledoc """
    Module provides api for fetching token from Sdek api
  """

  use HTTPoison.Base
  require Logger

  @endpoint "https://api.cdek.ru/v2"
  @test_endpoint "https://api.edu.cdek.ru/v2"

  def process_request_url(url) do
    case Application.get_env(:in_beauty, :env) do
      :prod ->
        @endpoint <> url
      _ -> @test_endpoint <> url
    end
  end

  def process_response_body(body) do
    #TODO what whould be if it couse an error ->
    case Jason.decode(body, keys: :atoms) do
      {:ok, body} ->
       Map.get(body, :access_token, nil)
      _ ->
        nil
    end
  end
end
