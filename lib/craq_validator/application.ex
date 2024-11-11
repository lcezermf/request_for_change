defmodule CraqValidator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CraqValidatorWeb.Telemetry,
      CraqValidator.Repo,
      {DNSCluster, query: Application.get_env(:craq_validator, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CraqValidator.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: CraqValidator.Finch},
      # Start a worker by calling: CraqValidator.Worker.start_link(arg)
      # {CraqValidator.Worker, arg},
      # Start to serve requests, typically the last entry
      CraqValidatorWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CraqValidator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CraqValidatorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
