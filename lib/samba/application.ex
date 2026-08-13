defmodule Samba.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    cert_path = Application.app_dir(:samba, "priv/cert")
    use_self_signed = System.get_env("USE_SIGNED_SSL") == nil

    if use_self_signed do
      Samba.SelfCertGenerator.generate_self_signed(cert_path)
    end

    frequency = Application.get_env(:samba, :frequency, 60_000)

    children = [
      CapsuleWeb.Server,
      SambaWeb.Telemetry,
      Samba.Repo,
      {Oban, AshOban.config([Samba.Accounts], Application.get_env(:samba, Oban))},
      {DNSCluster, query: Application.get_env(:samba, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Samba.PubSub},
      {Finch, name: Finch},
      Samba.Accounts.PasswordResetScheduler,
      Samba.Analytics.OnlineTracker,
      Samba.Analytics.PageTracker,
      SambaWeb.Presence,
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
