defmodule Serial.Connection do
  @moduledoc """
  Description of module.
  """

  use GenServer

  require Logger

  alias Circuits.UART

  # @ports "ttyUSB0"
  @baseport 5000
  @broadcastIP  {192, 168, 2, 255}
  @ownIP        {192, 168, 2, 144}

  @type usb_serial :: "ttyUSB" <> ("0" | "1" | "2" | "3")

  @spec start_link(usb_serial) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(serial_port_name) do
    GenServer.start_link __MODULE__, serial_port_name, name: __MODULE__
  end

  @impl true
  # @spec init(String) :: {:ok, {pid, port | {:"$inet", atom, any}}}
  @spec init(usb_serial) :: {:ok, {pid, port | {:"$inet", atom, any}}}
  def init(serial_port_name) do
    "ttyUSB"<>port_digit = serial_port_name
    {:ok, pid} = UART.start_link
    port = @baseport + String.to_integer(port_digit)
    {:ok, socket} = :gen_udp.open(port)
    UART.open(pid, serial_port_name,
      speed: 9600,
      active: true,
      framing: {UART.Framing.Line, separator: "\r\n"},
      rx_framing_timeout: 500,
      id: :pid)
    {:ok, {pid, socket, port}}
  end

  # def terminate do

  # end
  @impl true
  def handle_info({:circuits_uart, pid, {:error, error}}, {pid, socket, port}) do
    # terminate connection
    Logger.error(error)
    {:noreply, {pid, socket, port}}
  end

  def handle_info({:circuits_uart, pid, packet}, {pid, socket, port}) do
    :gen_udp.send(socket, @broadcastIP, port, packet)
    {:noreply, {pid, socket, port}}
  end

  def handle_info {:udp, _proc, @ownIP, _port, _msg}, {pid, socket, port} do
    {:noreply, {pid, socket, port}}
  end

  def handle_info {:udp, _proc, _ip, port, msg}, {pid, socket, port} do
    "CONFIG " <> config = msg
    if config do
      Poison.decode!(config)
      UART.configure(pid, config)
    else
      UART.write(pid, msg)
    end
    # UART.configure(pid, msg)
    {:noreply, {pid, socket, port}}
  end


  # receive do
  #   {:circuits_uart, @ports, {:error, :eio}} ->
  #     # terminate connection
  #   {:circuits_uart, @ports, msg} ->
  #     # code
  # end


end
