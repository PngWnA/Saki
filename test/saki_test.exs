defmodule SakiTest do
  use ExUnit.Case
  doctest Saki

  test "greets the world" do
    assert Saki.hello() == :world
  end
end
