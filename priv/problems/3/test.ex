ExUnit.start(seed: 0)

defmodule EventBuffer.Test do
  use ExUnit.Case, async: false

  setup do
    {:ok, _} = EventBuffer.start_link()
    :ok
  end

  test "concurrent event writes" do
    key = "user:123"
    opts = []
    count = 50

    results =
      1..count
      |> Enum.map(fn _ ->
        Task.async(fn ->
          EventBuffer.write("Event")
        end)
      end)
      |> Enum.map(&Task.await(&1, 1_000))

    expected =
      for n <- 1..50 do
        {n, "Event"}
      end

    assert EventBuffer.flush() == expected
  end
end
