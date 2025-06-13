defmodule Pidbit.ChangeListener do
  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @doc """
  Keeps the listener alive, but stops refreshing the matview when the
  notifications are received.
  """
  def pause do
    GenServer.call(__MODULE__, :pause)
  end

  @doc """
  Continues refreshing the matview after `pause/0` is called.
  """
  def continue do
    GenServer.call(__MODULE__, :continue)
  end

  @impl true
  def init(arg) do
    case Pidbit.Repo.listen("cached_record_updated") do
      {:ok, _pid, _ref} -> {:ok, arg}
      error -> {:stop, error}
    end
  end

  @impl true
  def handle_call(:pause, _from, :paused) do
    {:reply, {:error, :already_paused}, :paused}
  end

  def handle_call(:pause, _from, _state) do
    {:reply, :ok, :paused}
  end

  def handle_call(:continue, _from, :paused) do
    {:reply, :ok, []}
  end

  def handle_call(:continue, _from, state) do
    {:reply, {:error, :not_paused}, state}
  end

  @impl true
  def handle_info(_msg, :paused) do
    {:noreply, :paused}
  end

  def handle_info({:notification, _pid, _ref, "cached_record_updated", _payload}, state) do
    Pidbit.Cache.reset()

    {:noreply, state}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end
end
