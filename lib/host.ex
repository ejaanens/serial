defmodule Host do
  @moduledoc """
  Simple UDP to print module.
  """

  use GenServer

  def start_link {ip, port} do
    GenServer.start_link __MODULE__, {ip, port}, name: __MODULE__
  end

  def init {ip, port} do

    {:ok, {ip, port}}
  end

  def handle_info {:udp, _prc, ip, port, '$GPGGA,' ++ msg}, {ip, port} do
    <<
      utc::bytes-size(10), ",",
      lat::bytes-size(9),  ",", n_s::bytes-size(1), ",",
      lon::bytes-size(10), ",", e_w::bytes-size(1), ",",
      _fix::bytes-size(1), ",",
      sat::bytes-size(2),  ",",
      hdop::bytes-size(4), ",", var::bytes
    >> = to_string msg

    <<
      alt::bytes-size(5), ",", alt_u::bytes-size(1), ",",
      _geo_sep::bytes-size(4), ",", _geo_sep_u::bytes-size(1), ",",
      _dif_cor_age::bytes-size(0), ",",
      _sum::bytes-size(0), "*", _chk::binary>> = var

    <<hh::bytes-size(2), mm::bytes-size(2), ss::bytes-size(2), ".", _ms::bytes>> = utc
    <<lat_deg::bytes-size(2), lat_min::bytes-size(2), ".", lat_sec::bytes-size(2), _lat_rest::bytes>> = lat
    <<lon_deg::bytes-size(2), lon_min::bytes-size(2), ".", lon_sec::bytes-size(2), _lon_rest::bytes>> = lon

    IO.puts "#{hh}:#{mm}:#{ss}UTC"
    IO.puts "#{lat_deg}° #{lat_min}′ #{lat_sec}″ #{n_s}"
    IO.puts "#{lon_deg}° #{lon_min}′ #{lon_sec}″ #{e_w}"
    IO.puts "#{alt}#{alt_u}"
    IO.puts "satelites: #{sat} precision: #{hdop}"
    {:noreply, {ip, port}}
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
