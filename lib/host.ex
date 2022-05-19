defmodule Host do
  @moduledoc """
  Description of module.
  """

  use GenServer

  def start_link {ip, port} do
    GenServer.start_link __MODULE__, {ip, port}, name: __MODULE__
  end

  def init {ip, port} do

    {:ok, {ip, port}}
  end

  def handle_info {:udp, _prc, ip, port, msg}, {ip, port} do
    IO.puts msg
    {:noreply, {ip, port}}
  end

  def loop do
    receive do
      {:udp, _prc, {192, 168, 2, 144}, 5000, msg} -> IO.puts msg
    end
    :timer.sleep 100
    loop()
  end
end
