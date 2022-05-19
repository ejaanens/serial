defmodule Serial.Connection do
  @moduledoc """
  Description of module.
  """

  use GenServer

  require Logger

  alias Circuits.UART

  # @ports "ttyUSB"
  @baseport 5000
  @broadcastIP  {192, 168, 2, 236}
  @ownIP        {192, 168, 2, 144}

  # @type usb_serial :: <<_::48, _::_*8>>

  @spec start_link(<<_::48, _::_*8>>) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(serial_port_name) do
    GenServer.start_link __MODULE__, serial_port_name, name: __MODULE__
  end

  @impl true
  @spec init(<<_::48, _::_*8>>) :: {:ok, {pid, port | {:"$inet", atom, any}, char}}
  def init(serial_port_name) do
    "ttyUSB"<>port_digit = serial_port_name
    {:ok, usb} = UART.start_link
    port = @baseport + String.to_integer(port_digit)
    {:ok, socket} = :gen_udp.open(port)
    UART.open(usb, serial_port_name,
      framing: {UART.Framing.Line, separator: "\r\n"},
      id: :pid)
    {:ok, {usb, socket, port}}
  end

  @impl true
  def terminate(_reason, {usb, socket, _port}) do
    :gen_udp.close(socket)
    UART.close(usb)
  end

  @impl true
  def handle_info {:circuits_uart, usb, {:error, error}}, {usb, socket, port} do
    # TODO terminate connection?
    Logger.error(error)
    {:noreply, {usb, socket, port}}
  end

  def handle_info {:circuits_uart, usb, packet}, {usb, socket, port} do
    :gen_udp.send(socket, @broadcastIP, port, packet)
    {:noreply, {usb, socket, port}}
  end

  def handle_info {:udp, _prc, @ownIP, _port, _msg}, con do
    {:noreply, con}
  end

  def handle_info {:udp, _prc, _ip, port, 'CONF ' ++ json}, {usb, socket, port} do
    config = json
      |> Poison.decode!(as: %Serial.UART.Settings{})
      |> Map.to_list
      |> Enum.filter(fn {atom, val} -> val != nil and atom != :__struct__ end)
     UART.configure(usb, config)
    {:noreply, {usb, socket, port}}
  end

  def handle_info {:udp, _prc, _ip, port, msg}, {usb, socket, port} do
    UART.write(usb, msg)
    {:noreply, {usb, socket, port}}
  end


end
