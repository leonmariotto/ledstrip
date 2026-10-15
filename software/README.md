# Software design for led strip controller !

## Software Requirements

- Must read analog input from potentiometer.
- Must control N-channel mosfet with PWM.
- Must output log on UART.
- Must drive battery charger IC.
- Must drive USB PD IC.
- (Nice to have) output battery state on a LCD screen.

## Software Architecture

Use Zephyr RTOS:
- Driver for BQ25703A
- Driver for STUSB4500

## Zephyr workspace

The firmware is a west-managed, out-of-tree Zephyr application pinned to
Zephyr v4.4.2. The custom `ledstrip` board uses the STM32G030K6 and sends its
console output through USART1 on PA9 (TX) and PA10 (RX) at 115200 8N1.

### Prerequisites

Install west, CMake, Ninja, the Zephyr Python dependencies, and a Zephyr SDK or
another compatible ARM toolchain. See the Zephyr getting-started guide for the
host-specific setup.

From the repository root, initialize and fetch the workspace:

```sh
west init -l software
west update
```

### Build

```sh
west build -b ledstrip software/app -d software/build
```

### Flashing with J-Link

Install the SEGGER J-Link Software and Documentation Pack and ensure
`JLinkExe` is available on `PATH`. Connect the J-Link EDU to the board's
MIPI-10 SWD header, including VTref (3.3 V), GND, SWDIO, SWCLK, and nRESET.
The probe senses the target voltage through VTref; it does not power the board.

After building, flash the board with:

```sh
west flash
```

The board selects the J-Link runner, the `STM32G030K6` device, and a 4 MHz SWD
clock. `west debug` uses the same runner configuration.

All fetched sources are kept below `software/ext/`. To use a Zephyr fork,
change only the `url` and `revision` of the `zephyr` project in
`software/west.yml`, then run `west update` again.
