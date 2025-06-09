alias Pidbit.Repo
alias Pidbit.Problems.Problem

%Problem{
  id: 1,
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
|> Repo.insert!(on_conflict: :replace_all, conflict_target: [:id])

%Problem{
  id: 2,
  name: "Registry",
  slug: "registry",
  difficulty: :medium,
  description: """
  You are implementing a local process registry. The registry must support concurrent reads and writes, and it must ensure that only one process is ever started per string key.

  Your task is to implement a module with the following public functions:

  * `ProcRegistry.start_link(worker_module :: module()) :: GenServer.on_start()`
  * `ProcRegistry.get_or_start(worker_module :: module(), key :: String.t()) :: {:ok, pid()}`

  **Behavior**:

  * `start_link/1` starts the registry process.
  * `get_or_start/2`:
      * If a process for the given key already exists, returns its PID.
      * If no process exists for the key, starts a new short-lived GenServer (your implementation), stores it in the registry, and returns its PID.
      * Multiple concurrent calls to `get_or_start/2` with the same key must not start multiple processes.

  **Constraints**:

  * Only **one** `ProcRegistry` can be started for the given worker module
  * There will be tens of thousands of calls to `get_or_start/2` per second
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

    @spec get_or_start(module(), String.t()) :: {:ok, pid()}
    def get_or_start(worker_module, key) do
    end
  end
  """
}
|> Repo.insert!(on_conflict: :replace_all, conflict_target: [:id])
