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

  @type usb_serial :: "ttyUSB" <> <<_::_*8>>

  @spec start_link(usb_serial) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(serial_port_name) do
    GenServer.start_link __MODULE__, serial_port_name, name: __MODULE__
  end

  @impl true
  # @spec init(String) :: {:ok, {uart, port | {:"$inet", atom, any}}}
  @spec init(usb_serial) :: {:ok, {uart, port | {:"$inet", atom, any}}}
  def init(serial_port_name) do
    "ttyUSB"<>port_digit = serial_port_name
    {:ok, uart} = UART.start_link
    port = @baseport + String.to_integer(port_digit)
    {:ok, socket} = :gen_udp.open(port)
    UART.open(uart, serial_port_name,
      speed: 9600,
      active: true,
      framing: {UART.Framing.Line, separator: "\r\n"},
      rx_framing_timeout: 500,
      id: :pid)
    {:ok, {uart, socket, port}}
  end

  @impl true
  def terminate({uart, socket, port}) do
    UART.close()
  end

  @impl true
  def handle_info({:circuits_uart, uart, {:error, error}}, {uart, socket, port}) do
    # terminate connection
    Logger.error(error)
    {:noreply, {uart, socket, port}}
  end

  def handle_info({:circuits_uart, uart, packet}, {uart, socket, port}) do
    :gen_udp.send(socket, @broadcastIP, port, packet)
    {:noreply, {uart, socket, port}}
  end

  def handle_info {:udp, _proc, @ownIP, _port, _msg}, {uart, socket, port} do
    {:noreply, {uart, socket, port}}
  end

  def handle_info {:udp, _proc, _ip, port, msg}, {uart, socket, port} do
    "CONFIG " <> config = msg
    if config do
      Poison.decode!(config)
      UART.configure(uart, config)
    else
      UART.write(uart, msg)
    end
    # UART.configure(uart, msg)
    {:noreply, {uart, socket, port}}
  end


  # receive do
  #   {:circuits_uart, @ports, {:error, :eio}} ->
  #     # terminate connection
  #   {:circuits_uart, @ports, msg} ->
  #     # code
  # end


end
