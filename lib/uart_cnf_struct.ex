defmodule Serial.UART.Settings do
   @derive [Poison.Encoder]
   defstruct [
    :active,
    :speed,
    :databits,
    :stopbits,
    :parity,
    :flowcontrol,
    :framing,
    :rx_framing_timeout
  ]
end
