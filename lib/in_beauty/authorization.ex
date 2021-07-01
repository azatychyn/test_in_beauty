defmodule InBeauty.Authorization do
  alias __MODULE__

  defstruct role: nil,
    create: %{},
    update: %{},
    delete: %{},
    sign_in: %{},
    sign_up: %{},
    sign_out: %{},
    reset_password: %{},
    confirm_email: %{},
    index: %{},
    change_password: %{},
    checkout: %{},
    settings: %{},
    profile: %{},
    filters: %{}

  def can("anon" = role) do
    grant(role)
    |> sign_up("User")
    |> sign_in("User")
    |> reset_password("User")
    |> create("User")
    |> index("Product")
    |> create("Order")
    |> checkout("Order")
    |> create("Review")
    |> create("Message")
  end

  def can("user" = role) do
    grant(role)
    |> sign_out("User")
    |> update("User")
    |> index("Product")
    |> create("Order")
    |> checkout("Order")
    |> create("Review")
    |> create("Message")
  end

  def can("admin" = role) do
    grant(role)
    |> sign_out("User")
    |> all("Product")
    |> all("User")
    |> all("Cart")
    |> all("Order")
    |> checkout("Order")
    |> all("Review")
    |> all("Message")
  end

  def grant(role), do: %Authorization{role: role}

  def create(authorization, resource), do: put_action(authorization, :create, resource)

  def update(authorization, resource), do: put_action(authorization, :update, resource)

  def delete(authorization, resource), do: put_action(authorization, :delete, resource)

  def sign_in(authorization, resource), do: put_action(authorization, :sign_in, resource)

  def sign_up(authorization, resource), do: put_action(authorization, :sign_up, resource)

  def sign_out(authorization, resource), do: put_action(authorization, :sign_out, resource)

  def reset_password(authorization, resource), do: put_action(authorization, :reset_password, resource)

  def index(authorization, resource), do: put_action(authorization, :index, resource)


  def checkout(authorization, resource), do: put_action(authorization, :checkout, resource)

  def all(authorization, resource) do
    authorization
    |> create(resource)
    |> update(resource)
    |> delete(resource)
    |> index(resource)
  end

  def create?(authorization, resource) do
    Map.get(authorization.create, resource, false)
  end

  def update?(authorization, resource) do
    Map.get(authorization.update, resource, false)
  end

  def delete?(authorization, resource) do
    Map.get(authorization.delete, resource, false)
  end

  def sign_in?(authorization, resource) do
    Map.get(authorization.sign_in, resource, false)
  end

  def sign_up?(authorization, resource) do
    Map.get(authorization.sign_up, resource, false)
  end

  def sign_out?(authorization, resource) do
    Map.get(authorization.sign_out, resource, false)
  end

  def reset_password?(authorization, resource) do
    Map.get(authorization.reset_password, resource, false)
  end

  def index?(authorization, resource) do
    Map.get(authorization.index, resource, false)
  end

  def checkout?(authorization, resource) do
    Map.get(authorization.checkout, resource, false)
  end

  defp put_action(authorization, action, resource) do
    updated_action =
      authorization
      |> Map.get(action)
      |> Map.put(resource, true)

    Map.put(authorization, action, updated_action)
  end

  def get_resource(module), do: String.replace("#{module}", ~r/.+\.(.+)Live.+/, "\\1")
  def get_resource(_), do: nil
end
