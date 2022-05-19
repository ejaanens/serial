defmodule Serial.Detect do
  @moduledoc """
  Detects USB serial devices.
  """

  use GenServer

  alias Circuits.UART

  alias Serial.Connection

  @spec start_link(list(String)) :: :ignore | {:error, any} | {:ok, pid}
  def start_link detected_ports do
    GenServer.start_link __MODULE__, detected_ports, name: __MODULE__
  end

  defp periodic do
    Process.send_after self(), :check_usb, 1000
  end

  @impl true
  @spec init(list(String)) :: {:ok, any}
  def init detected_ports do
    periodic()
    {:ok, detected_ports}
  end

  @impl true
  def handle_info :check_usb, detected_ports do
    periodic()
    serial_ports = UART.enumerate |> Map.drop(detected_ports)
    serial_port = serial_ports |> Map.keys |> Enum.at(0)
    if serial_port != nil do
      Connection.start_link(serial_port)
      {:noreply, [serial_port | detected_ports]}
    else
      {:noreply, detected_ports}
    end
  end
end
