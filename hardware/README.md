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
- I2C to BQ25703A: PB6 (SCL), PB7 (SDA)
- PWM to MOSFET: PA8, PA6, PA7
- Power pins: VDD, VDDA, VSS, VSSA (decouple properly)
- BQ25703A_PROCHOT: PB9
- BQ25703A_CHRG_OK: PB9
Note that PWM need to use TIM1 for PA0 and TIM3 for PA6 and PA7 due conflicts with UART.

# TODO
- Add a buck converter to output the 3.3V.
- Enable DRC checker and releases jobs in github actions when possible.
- Use KiBot for CI/CD: https://kibot.readthedocs.io/en/master/usage_with_ci_cd.html#usage-of-github-actions
It looks like an old, complicate tool. It may do more than the current sparkengineering kicad action
but this one is a simple bash script running kicad-cli v9.

## TODO BQ25703A nice-to-have !

- IADPT (pin 8) – adapter current monitor
Output proportional to input current: V(IADPT) = 20× or 40× (V(ACP − ACN)), selectable by register.
Hardware connection per datasheet:
Resistor from IADPT → GND (e.g. 137 kΩ for 2.2 µH as in datasheet example).
≤100 pF cap from IADPT → GND for noise filtering.
Optionally route that node to an MCU ADC to see “adapter current” in mA.
If you don’t care: leave IADPT floating (no resistor, no cap).
- IBAT (pin 9) – battery charge/discharge current
Output proportional to battery current across SRP/SRN: 8× or 16× gain.
Hardware:
≤100 pF cap from IBAT → GND (if used).
Optional resistor to GND + ADC input like IADPT.
If you don’t need an analog battery-current pin: leave IBAT floating (only the pin, not the sense resistor!).
- PSYS (pin 10) – system power monitor
Outputs current proportional to total system power (adapter + battery). Gain is ~1 µA/W with voltage clamped below 3.3 V.
Hardware:
Resistor PSYS → GND to convert current to a voltage (target <3.3 V at max power).
Optional small cap in parallel for filtering.
Route the node to an MCU ADC if you want real-time “how many watts am I using?” info.
If you don’t want this feature: leave PSYS floating.

## TODO STUSB4500 nice-to-have !

- POWER_OK2/POWER_OK3 to MCU
- ATTACH to MCU
- I2C to MCU ?

## TODO better kicad sheets !

- Name label
- Color wires
- Add commentary
