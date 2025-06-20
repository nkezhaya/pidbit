defmodule ProcRegistry do
  use GenServer
  require Logger

  @spec start_link(module()) :: GenServer.on_start()
  def start_link(worker_module) do
    name = registry_name(worker_module)

    GenServer.start_link(__MODULE__, [worker_module: worker_module], name: name)
  end

  @impl true
  def init(arg) do
    worker_module = arg[:worker_module]
    Process.flag(:trap_exit, true)

    tid =
      :ets.new(table_name(worker_module), [
        :set,
        :named_table,
        :protected,
        {:read_concurrency, true},
        {:write_concurrency, true}
      ])

    {:ok, %{worker_module: worker_module, tid: tid}}
  end

  @spec fetch_or_start(module(), String.t(), [term()]) :: {:ok, pid()} | {:error, term()}
  def fetch_or_start(worker_module, key, options) do
    table = table_name(worker_module)

    case :ets.lookup(table, key) do
      [] ->
        name = registry_name(worker_module)
        GenServer.call(name, {:start, key, options})

      [{_, pid}] ->
        {:ok, pid}
    end
  end

  @impl true
  def handle_call({:start, key, options}, _from, %{worker_module: worker_module} = state) do
    table = table_name(worker_module)

    result =
      case :ets.lookup(table, key) do
        [] ->
          case worker_module.start_link(options) do
            {:ok, pid} ->
              :ets.insert(table, [{key, pid}, {pid, key}])

              {:ok, pid}

            error ->
              error
          end

        [{_key, pid}] ->
          {:ok, pid}
      end

    {:reply, result, state}
  end

  @impl true
  def handle_info({:EXIT, pid, _reason}, state) do
    %{worker_module: worker_module} = state
    table = table_name(worker_module)

    case :ets.lookup(table, pid) do
      [] ->
        nil

      [{pid, key}] ->
        :ets.delete(table, key)
        :ets.delete(table, pid)
    end

    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.info("Unexpected message: #{msg}")

    {:noreply, state}
  end

  defp table_name(worker_module), do: :"proc_registry_#{worker_module}_ets"
  defp registry_name(worker_module), do: Module.concat(__MODULE__, worker_module)
end
