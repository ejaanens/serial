defmodule Serial.UART.Settings do
   @derive [Poison.Encoder]
   defstruct [
    :active,    # true | false
    :speed,     # integer i.e. 9600..115200
    :databits,  # 5..8
    :stopbits,  # 1..2
    :parity,    # :none`, `:even`, `:odd`, `:space`, or `:mark`) set the
    # parity. Usually this is `:none`. Other values:
    # * `:space` means that the parity bit is always 0
    # * `:mark` means that the parity bit is always 1
    # * `:ignore` means that the parity bit is ignored (unix only
    :flowcontrol, # :none | :hardware | :software
    :framing,     # module | {module, args} uses Circuits.UART.Framing
    :rx_framing_timeout # integer in ms negative meaning :inf
  ] # :id :name :pid
end
