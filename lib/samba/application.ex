defmodule Samba.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SambaWeb.Telemetry,
      Samba.Repo,
      {DNSCluster, query: Application.get_env(:samba, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Samba.PubSub},
      {Finch, name: Finch},
      # Start a worker by calling: Samba.Worker.start_link(arg)
      # {Samba.Worker, arg},
      # Start to serve requests, typically the last entry
      SambaWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :samba]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Samba.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SambaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
