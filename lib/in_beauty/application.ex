defmodule InBeauty.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      InBeauty.Repo,
      # Start the Telemetry supervisor
      InBeautyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: InBeauty.PubSub},
      # Start the Endpoint (http/https)
      InBeautyWeb.Endpoint,
      # Start a worker by calling: InBeauty.Worker.start_link(arg)
      # {InBeauty.Worker, arg}
      con_cache_child_spec(:sdek_cache, false),
      con_cache_child_spec(:session_data, 2_592_000)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: InBeauty.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp con_cache_child_spec(name, false) do
    Supervisor.child_spec(
      {
        ConCache,
        [
          name: name,
          ttl_check_interval: false
        ]
      },
      id: {ConCache, name}
    )
  end
  defp con_cache_child_spec(name, global_ttl) do
    Supervisor.child_spec(
      {
        ConCache,
        [
          name: name,
          ttl_check_interval: :timer.seconds(1),
          global_ttl: :timer.seconds(global_ttl)
        ]
      },
      id: {ConCache, name}
    )
  end
  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    InBeautyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
