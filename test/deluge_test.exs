defmodule DelugeTest do
  use ExUnit.Case
  doctest Deluge

  test "greets the world" do
    assert Deluge.hello() == :world
  end
end
