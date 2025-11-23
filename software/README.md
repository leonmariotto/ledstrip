# Software design for led strip controller !

## Prototype hardware list

- STM32G0 nucleo
- Led strip
- 3 potentiometer
- 3 N-channel mosfet

## Software Requirements

- Must read analog input from potentiometer.
- Must control N-channel mosfet with PWM.
- Must output log on UART.
- Must drive battery charger IC.
