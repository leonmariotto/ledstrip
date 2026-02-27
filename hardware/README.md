# Hardware design for led strip controller !

## Hardware Requirements

- Must have a on/off switch
- Must provide a USB-C socket
- Must use a serie of Li-Ion battery along with a BMS
- Must use USB-C Power Delivery feature for efficient charging.
- Must use one potentiometer to control one color.
- Must provide an easy access to log via USB.
- Must support run while charging battery.
- Must provide protections against heating and short circuit.

## Ledstrip part !

Choosen RGBW ledstrip of 2 meters.
https://opencircuit.fr/produit/analog-rgbw-led-strip-rgb-plus-warm-white-60

## Hardware Architecture Design

So far the following components is identified :
- 3S Li-ion battery pack. 12V output.
- 3S BMS: off the shelf 3S (3-cells) BMS module. Shall support currents >
to expected (for 2 meter strip the expected current is 3.2A at 12V. So design it to 5-10A.
Start with an external BMS module, then progressively move into an integrated
BMS.
- USB-C connector
- USB to UART bridge (Silicon Labs CP2102(N), or FTDI FT230x or CH340)
- USB Power Delivery controller (ST STUSB4500) used to negociate high power input from USB.
- Battery charger IC (BQ25703A) : accept PD voltage and implement CC/CV.
Provide support for system load while charging.
- Buck regulator (12V to 3.3V) : integrated converter IC
- Logic-level N-MOSFETS x3, low RDS(on).
- Gate resistor / gate pull-down for each MOSFET, Fuse, ESD protections (TVS diodes, Schottky),
- Dedicated MIPI-10 connector for SWD.
- STM32G030K6 MCU.

### STM32G030K6 32-bit LQFP package

Use the following wiring :
- SWD: PA13, PA14, NRST
- UART: PA9 (TX), PA10 (RX)
- ADC (pots): PA0, PA1, PA2
- I2C to BQ25703A: PB6 (SCL), PB7 (SDA)
- PWM to MOSFET: PA8, PA6, PA7
- Power pins: VDD, VDDA, VSS, VSSA (decouple properly)
- BQ25703A_PROCHOT: PB9
- BQ25703A_CHRG_OK: PB9
Note that PWM need to use TIM1 for PA0 and TIM3 for PA6 and PA7 due to conflicts with UART.

## Building

A CI is here to build Gerber on a stable and reproducible environment.
PCBway is the recommended manufacturer.

## 4 layers

- Top (F.Cu): components + most routing (especially short local routes)
- Inner 1: solid GND plane (no splits)
- Inner 2: power pours (3.3 V, 12 V) + only necessary routing (prefer short, controlled routes)
- Bottom (B.Cu): routing + GND pour (stitched to Inner 1 often); use power pours only where it clearly helps (short distribution or local planes)

# TODO

- Create missing 3D view for footprint that lack it.
- Add 20 ohm serie resistor after TVS at each USB input.
- Ensure that global parameters are OK.
- Add more space between components (except coupling caps and TVS diodes)
- Change pin assignment to reduce tracks crossing.
- Enable DRC checker and releases jobs in github actions when possible.

