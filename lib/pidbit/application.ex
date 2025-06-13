defmodule Pidbit.Application do
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

      # Phoenix
      {Phoenix.PubSub, name: Pidbit.PubSub},
      {Finch, name: Pidbit.Finch},
      PidbitWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Pidbit.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    PidbitWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
