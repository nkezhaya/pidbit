defmodule Pidbit.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PidbitWeb.Telemetry,
      Pidbit.Repo,

      # Cache
      {Cachex, [:pidbit_cache]},
      Pidbit.ChangeListener,

      {Phoenix.PubSub, name: Pidbit.PubSub},
      {Finch, name: Pidbit.Finch},
      PidbitWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pidbit.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PidbitWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
