defmodule Host do
  @moduledoc """
  Description of module.
  """

  use GenServer

  def start_link state do
    GenServer.start_link __MODULE__, state, name: __MODULE__
  end

  def init state do

    {:ok, state}
  end
end
