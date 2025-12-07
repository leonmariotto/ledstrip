• STUSB4500 integration review

  - RESET permanently pulled down: RESET (pin 6) is only tied through R11=47 k to GND (net Net-(U6-RESET)), no
    pull-up to VDD/3V3. That will hold the STUSB4500 in reset and it will never power up. Add a pull-up (e.g.,
    10 k to 3V3) and an optional test pad; keep the GND resistor only if you’re forming an RC to ground (then add
    a series cap), otherwise remove the pull-down.
  - Missing VBUS discharge path and incorrect use of DISCH: DISCH (pin 9) only goes via R12=1 k to V_SNK. There
    is no dedicated discharge FET/resistor to ground as shown in the ST reference (DISCH should drive an N-MOS/
    resistor to bleed VBUS). As drawn, the pin can’t discharge the connector and may violate detach timing. Add
    the recommended NMOS+resistor discharge network from the datasheet, or at least a bleed resistor to ground
    sized per spec.
  - VBUS sense / VBUS_VS_DISCH pin overvoltage risk: VBUS_VS_DISCH (pin 18) is tied to VBUS through only R6=1 k
    (Net-(D2-K)) with no divider to ground. With PD voltages up to 20 V, that pin will see nearly full VBUS (only
    1 k series), exceeding the pin rating and the recommended divider (typically 1 M/100 k range). Implement the
    datasheet’s resistor divider to keep the pin within its allowed voltage.
  - STUSB4500 status outputs not used: ATTACH (pin 11), POWER_OK2 (pin 20), POWER_OK3 (pin 14), and ALERT (pin
    19) are pulled up to 3V3 (R7/R8/R10=4.7 k) but go only to testpoints. If you want the MCU or charger to react
    to attach/contract changes or fault alerts, wire these to MCU GPIOs or to the charger enable path per the
    reference design.
  - I²C only on header: SCL/SDA go to J6 pins 2/3 with 4.7 k pull-ups to 3V3, but not to the MCU. If the MCU
    should control or monitor PDOs, route SCL/SDA to the MCU as well; otherwise you’re limited to external
    programming only.
  - VDD supply path sanity check: VDD (pin 24) is fed from VBUS through D2 (Schottky) and R2=10 mΩ with C9=1 µF.
    Confirm the Schottky orientation and that R5/R6/R12 network matches the ST “VBUS sensing” reference (R5=470 Ω
    between VBUS and VDD is unusual; compare to datasheet values and adjust to meet UVLO/OVP requirements).
  - Open-drain gate drive: VBUS_EN_SNK (pin 16) drives Q4 gate via R14=1 k with 100 k pull-up (R13) to V_SNK,
    which is consistent with enabling the PFET. Ensure the PFET and gate resistors match the ST load-switch
    example and that source/drain orientation gives correct body diode direction (diode should conduct from
    connector to system).

  Recommended fixes before layout

  - Add proper RESET pull-up to 3V3 (and optional RC to ground), remove the hard pull-down.
  - Implement the ST discharge circuit: DISCH -> gate resistor -> NMOS; NMOS pulls VBUS (or VDD node) to ground
    through a sized resistor per datasheet to meet tDISCH.
  - Add the required resistor divider for VBUS_VS_DISCH pin per ST reference (e.g., ~1 M/100 k; verify exact
    recommended values) and place it close to the IC.
  - Revisit the VBUS sensing/conditioning network (D2, R2, R5/R6/R12) against the ST reference schematic; align
    resistor values and topology to the recommended OVP/UVLO and discharge design.
  - If MCU visibility is desired, route ATTACH, POWER_OK2/3, ALERT (and optionally VBUS_EN_SNK status) to MCU
    GPIOs; otherwise document that only external header access exists.
  - If MCU control is desired, also route SCL/SDA to the MCU while keeping the header for flashing/debugging.

