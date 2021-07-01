defmodule InBeautyWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :in_beauty

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_in_beauty_key",
    signing_salt: "A650etG/",
    max_age: 2_592_000
    # store: :redis,
    # key: "_in_beauty_key",
    # expiration_in_seconds: 3000 # Optional - default is 30 days
    # key: "_in_beauty_key",
    # store: PlugSessionMnesia.Store
  ]

  socket "/socket", InBeautyWeb.UserSocket,
    websocket: true,
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :in_beauty,
    gzip: false,
    only: ~w(css fonts images leaflet leaflet.markercluster.js MarkerCluster.css MarkerCluster.Default.css js favicon.ico robots.txt uploads)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :in_beauty
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug InBeautyWeb.Router
end
