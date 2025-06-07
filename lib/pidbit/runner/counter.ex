defmodule Pidbit.Runner.Counter do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  @impl true
  def init(_) do
    {:ok, 0}
  end

  @impl true
  def handle_call(:get, _, state) do
    state = state + 1

    {:reply, state, state}
  end
end
