ExUnit.start(seed: 0)

defmodule ProcRegistry.Test do
  use ExUnit.Case, async: false

  defmodule DummyWorker do
    use GenServer

    def start_link(opts) do
      GenServer.start_link(__MODULE__, opts)
    end

    def init(opts) do
      Process.send_after(self(), :exit, 5000)
      {:ok, opts}
    end
  end

  setup do
    {:ok, _} = ProcRegistry.start_link(DummyWorker)
    :ok
  end

  test "concurrent fetch_or_start for same key only starts one process" do
    key = "user:123"
    opts = []

    results =
      1..50
      |> Enum.map(fn _ ->
        Task.async(fn ->
          ProcRegistry.fetch_or_start(DummyWorker, key, opts)
        end)
      end)
      |> Enum.map(&Task.await(&1, 1_000))

    [{:ok, pid} | rest] = results
    assert Enum.all?(rest, fn {:ok, pid2} -> pid2 == pid end)
  end
end
