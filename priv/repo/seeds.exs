alias Pidbit.Repo
alias Pidbit.Problems.Problem

defmodule Seeds do
  def insert(problem) do
    stub = String.trim(problem.stub)

    problem
    |> Problem.changeset(%{stub: stub})
    |> Repo.insert!(on_conflict: {:replace_all_except, [:id]}, conflict_target: [:number])
  end
end

%Problem{
  number: 1,
  name: "Hello World",
  slug: "hello-world",
  difficulty: :easy,
  description: """
  Write a function that returns `"Hello, world!"`
  """,
  stub: """
  defmodule Hello do
    def world do
    end
  end
  """
}
|> Seeds.insert()

%Problem{
  number: 2,
  name: "Registry",
  slug: "registry",
  difficulty: :medium,
  description: """
  You are implementing a local process registry. The registry must support concurrent reads and writes, and it must ensure that only one process is ever started per string key.

  Your task is to implement a module with the following public functions:

  ```elixir
  start_link(
    worker_module :: module()
  ) :: GenServer.on_start()

  fetch_or_start(
    worker_module :: module(),
    key :: String.t(),
    opts :: keyword()
  ) :: {:ok, pid()}
  ```

  **Behavior**:

  * `start_link/1` starts the registry process.
  * `fetch_or_start/3`:
    * Starts the worker module with the given `opts`
    * If a process for the given key already exists, returns its PID.
    * If no process exists for the key, starts a new short-lived GenServer (your implementation), stores it in the registry, and returns its PID.
    * Multiple concurrent calls to `fetch_or_start/3` with the same key must not start multiple processes.

  **Example**:

  ```elixir
  {:ok, _} = ProcRegistry.start_link(MyModule)
  {:ok, pid} = ProcRegistry.fetch_or_start(MyModule, "key1")
  pid #=> #PID<0.693.0>
  {:ok, pid} = ProcRegistry.fetch_or_start(MyModule, "key1")
  pid #=> #PID<0.693.0>
  {:ok, pid} = ProcRegistry.fetch_or_start(MyModule, "key2")
  pid #=> #PID<0.712.0>
  ```

  **Constraints**:

  * Only **one** `ProcRegistry` can be started for the given worker module
  * There will be tens of thousands of calls to `fetch_or_start/3` per second
  * New processes are started at a rate of dozens per second
  * Each registered process lives for around 10 seconds
  * The registry is local only (no distribution)
  * Do not use any external libraries, including `Registry` or `gproc`
  * Assume keys are arbitrary strings of reasonable length
  """,
  stub: """
  defmodule ProcRegistry do
    @spec start_link(module()) :: GenServer.on_start()
    def start_link(worker_module) do
    end

    @spec fetch_or_start(module(), String.t(), keyword()) :: {:ok, pid()}
    def fetch_or_start(worker_module, key, opts) do
    end
  end
  """
}
|> Seeds.insert()

%Problem{
  number: 3,
  name: "Event Buffer",
  slug: "event-buffer",
  difficulty: :hard,
  description: """
  You are implementing a high-performance, in-memory event buffer that supports concurrent writes and flushing of events in order.

  Your task is to implement a module EventBuffer with the following public functions:

  * `EventBuffer.start_link()`
  * `EventBuffer.write(event :: String.t()) :: :ok`
  * `EventBuffer.flush() :: [{pos_integer(), String.t()}]`

  **Behavior**:

  * `start_link/0` initializes the buffer process and any necessary internal state.
  * `write/1` appends an event to the buffer:
    * Assigns it a monotonically increasing integer ID, starting from 1
    * Returns `:ok`
  * `flush/0` returns all events in the order they were written, and empties the buffer
  * The function returns a list of tuples, where the first element is the unique ID of the event, and the second element is the event string passed to `write/1`

  **Constraints**:

  * `write/1` must support tens of thousands of concurrent calls per second
  * Only one instance of `flush/0` will be called at a time
  * `flush/0` must be synchronous
  * Each event must be flushed exactly once
  """,
  stub: """
  defmodule EventBuffer do
    @spec start_link() :: GenServer.on_start()
    def start_link do
    end

    @spec write(String.t()) :: :ok
    def write(event) do
    end

    @spec flush() :: [{pos_integer(), String.t()}]
    def flush() do
    end
  end
  """
}
|> Seeds.insert()
