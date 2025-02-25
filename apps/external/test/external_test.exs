defmodule ExternalTest do
  use ExUnit.Case
  doctest External

  test "greets the world" do
    assert External.hello() == :world
  end
end
