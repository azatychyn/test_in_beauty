defmodule InBeauty.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `InBeauty.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "helloWorld!1996"
  def invalid_user_password, do: "helloworld"

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        password: valid_user_password(),
        role: "user",
        first_name: "david",
        phone_number: "7999#{Enum.random(10000..99999)}99"
      })
      |> InBeauty.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end
end
