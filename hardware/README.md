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
- Battery charger IC (BQ25703A) : accept PD voltage and implement CC/CV.
Provide support for system load while charging.
- Buck regulator (12V to 3.3V) : integrated converter IC
- Logic-level N-MOSFETS x3, low RDS(on).
- Gate resistor / gate pull-down for each MOSFET.
- Fuse
- Protection against brutal voltage spike/drop: Transient Voltage Drop (TVS diode).
- Reverse polarity protection: Schottky diode. Protect against inversing power.
- Thermal Sensor near the cell
- Dedicated MIPI-10 connector for SWD.
- AdaFruit RGBW Analog (Warm white): 2 meters.

### STM32G030K6 32-bit LQFP package

Use the following wiring :
- SWD: PA13, PA14, NRST
- UART: PA9 (TX), PA10 (RX)
- ADC (pots): PA0, PA1, PA2
- PWM to MOSFET: PA8, PA6, PA7
- Power pins: VDD, VDDA, VSS, VSSA (decouple properly)
Note that PWM need to use TIM1 for PA0 and TIM3 for PA6 and PA7 due conflicts with UART.

# TODO
- Add a 10 ohm resistor on VDD I2C header line for protection.
- Add a TVS diode on VBUS line for ESD protection.
- Add a high side FET :
N-MOSFET, ≥ 30 V, low Rds(on).
Source to USB-C VBUS, drain to 15V_OUT → BQ25703A VIN.
Gate driven by STUSB4500’s “VBUS_EN/PWR_OK” (possibly via gate resistor).
- Integrate BQ25703A
- Create a symbol for BMS (external module)
- Integrate 3 potentiometer.
- Integrate and choose 3 N-channel mosfet for led color control. 
