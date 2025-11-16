# Led Strip Project !

The goal here is to make a led strip that just work.
The layout is :
- hardware: kicad project to make the led strip controller board.
- cad: printable case for the controller + battery
- software: software used to control the led strip.

# System requirements

- Must have a on/off switch
- Must have a battery properly scaled.
- Must provide a way to control color independently.
- Leds must be RGB with controllable intensity.
- Must provide a way to charge battery
- Must provide a way to program firmware.
- Must provide a way to program internal flash of MCU.

# Hardware 

- AdaFruit RGBW Analog (Warm white) : https://www.adafruit.com/product/2589
- The tricky part is clearly the BMS for recharging battery.
- Put a socket to led strip, to easily remove it from the board.

# Software

- Take inputs from 3 analog pin
- Output to 3 PWM pins
- Put zephyr for fun.
