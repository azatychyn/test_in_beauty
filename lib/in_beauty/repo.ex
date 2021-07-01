defmodule InBeauty.Repo do
  use Ecto.Repo,
    otp_app: :in_beauty,
    adapter: Ecto.Adapters.Postgres

    use Scrivener,
      page_size: 10
end
