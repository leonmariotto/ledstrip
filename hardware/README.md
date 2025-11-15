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

## Hardware Architecture Design

So far the following components is identified :
- 3S Li-ion battery pack.
- 3S BMS: off the shelf 3S (3-cells) BMS module. Shall support currents >
to expected (for 2 meter strip the expected current is 3.2A at 12V. So design it to 5-10A.
Start with an external BMS module, then progressively move into an integrated
BMS.
- USB-C connector
- USB to UART bridge (Silicon Labs CP2102(N), or FTDI FT230x or CH340)
- USB Power Delivery controller (ST STUSB4500)
- Battery charger IC : accept PD voltage and implement CC/CV. Provide support for
system load while charging.
- Buck regulator (12V to 3.3V) : integrated converter IC
- Logic-level N-MOSFETS x3, low RDS(on).
- Gate resistor / gate pull-down for each MOSFET.
- Fuse
- Transient protection on 12V rail
- Reverse polarity protection, Schottky
- Thermal Sensor near the cell
- Dedicated MIPI-10 connector for SWD.
- LED strip adafruit RGBW analog 2 meters.

