ExUnit.start(seed: 0)

defmodule Hello.Test do
  use ExUnit.Case, async: false

  test "returns hello world" do
    assert Hello.world() == "Hello, world!"
  end
end
