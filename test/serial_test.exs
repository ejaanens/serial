defmodule SerialTest do
  use ExUnit.Case
  doctest Serial

  test "greets the world" do
    assert Serial.hello() == :world
  end
end
