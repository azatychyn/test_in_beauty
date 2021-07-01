defmodule InBeauty.Sdek.Token do
  @moduledoc """
    Module provides token methods, fetch token from Cds api and put it in cache
  """
  alias InBeauty.Sdek.TokenClient
  require Logger

  @spec get_token() :: String.t() | nil
  def get_token(), do: get_token_from_cache(ConCache.get(:sdek_cache, :token))

  @spec get_token_from_cache(String.t() | nil) :: String.t()
  defp get_token_from_cache(nil), do: update_token()
  defp get_token_from_cache({created_datetime, token}) do
    diff_datetime =
      DateTime.utc_now()
      |> DateTime.diff(created_datetime)
      |> abs()
    case diff_datetime < 3_500 do
      true ->
        token
      _ ->
        update_token()
    end
  end


  @spec client_id() :: String.t()
  def client_id() do
    case Application.get_env(:in_beauty, :env) do
      :prod ->
        Application.get_env(:in_beauty, :cds_client_id)
      _ ->
        "EMscd6r9JnFiQ3bLoyjJY6eM78JrJceI"
    end
  end

  @spec client_secret() :: String.t()
  def client_secret() do
    case Application.get_env(:in_beauty, :env) do
      :prod ->
        Application.get_env(:in_beauty, :cds_client_secret)
      _ ->
        "PjLZkKBHEiLK3YsjtNrt3TGNG0ahs3kG"
    end
  end

  @spec update_token() :: String.t() | nil
  defp update_token() do
    url = "/oauth/token"
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
    body = {:form, [
      {"client_secret", client_secret()},
      {"client_id", client_id()},
      {"grant_type", "client_credentials"}
    ]}

    case TokenClient.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: token}} ->
        Logger.info "Cds token was successfully updated"
        ConCache.put(:sdek_cache, :token, {DateTime.utc_now(), token})
        token
      _ ->
        nil
    end
  end
end
