defmodule TicTacToeEx.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TicTacToeExWeb.Telemetry,
      TicTacToeEx.Repo,
      {DNSCluster, query: Application.get_env(:tic_tac_toe_ex, :dns_cluster_query) || :ignore},
      {Oban, Application.fetch_env!(:tic_tac_toe_ex, Oban)},
      {Phoenix.PubSub, name: TicTacToeEx.PubSub},
      # Start a worker by calling: TicTacToeEx.Worker.start_link(arg)
      # {TicTacToeEx.Worker, arg},
      {Registry, keys: :unique, name: TicTacToeEx.GameRegistry},
      {PartitionSupervisor,
       child_spec: DynamicSupervisor, name: TicTacToeEx.DynamicGameSupervisors},
      # Start to serve requests, typically the last entry
      TicTacToeExWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TicTacToeEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TicTacToeExWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
