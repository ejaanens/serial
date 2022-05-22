defmodule ConnectionTest do
  use ExUnit.Case
  use PropCheck
  import Serial.Connection
  alias Serial.Connection
  doctest Connection

  # test "start GenServer" do
  #   assert start_link("ttyUSB0") == {:ok,  pid()}
  #   assert start_link("ttyUSB1") == {:ok,  pid()}
  #   assert start_link("ttyUSB2") == {:ok,  pid()}
  #   assert start_link("ttyUSB3") == {:ok,  pid()}
  # end

  property "start GenServer" do
    check all strings <- string() do
      assert start_link(strings) == string()
    end
  end
end
