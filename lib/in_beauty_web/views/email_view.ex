defmodule InBeautyWeb.EmailView do
  use InBeautyWeb, :view

  def full_path() do
    case Application.get_env(:in_beauty, :env) do
      :prod ->
        "https://in_beauty.com"
      _ ->
        "http://localhost:4000"
    end
  end
end
