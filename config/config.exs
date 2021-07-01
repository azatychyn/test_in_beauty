# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :in_beauty,
  ecto_repos: [InBeauty.Repo]

# Configures the endpoint
config :in_beauty, InBeautyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4yfq/OihxrLVua4Mv1wKRlvk+YXalJhBeC4AdVxHoMRHPgJjpqvqrY+BAoYKjF6S",
  render_errors: [view: InBeautyWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: InBeauty.PubSub,
  live_view: [signing_salt: "KchU96XJ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :in_beauty, InBeauty.FeedBack.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.yandex.ru",
  hostname: "www.mydomain.com",
  port: 587,
  username: "dgs0196@yandex.ru", # or {:system, "SMTP_USERNAME"}
  password: "streamingis", # or {:system, "SMTP_PASSWORD"}
  tls: :always, # can be `:always` or `:never`
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
  # or {":system", ALLOWED_TLS_VERSIONS"} w/ comma seprated values (e.g. "tlsv1.1,tlsv1.2")
  ssl: false, # can be `true`,
  retries: 1,
  no_mx_lookups: false, # can be `true`
  auth: :always # can be `always`. If your smtp relay requires authentication set it to `always`.

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
