# PTV09A-6030U: simplified enclosure model

Use `PTV09A-6030U_envelope.step` for RV1–RV4. It contains three solids: a housing envelope, a smooth bushing, and a smooth shaft. Open it in FreeCAD to inspect it; it is ready for KiCad without further modeling.

## Dimensions and accuracy

Source: local `ptv09.pdf`, pages 2–3, PTV09A-6 drawing and U shaft table.

| Feature | Model |
|---|---|
| Housing width across terminal row | 10 mm |
| Housing extent toward terminal row from shaft axis | 6.5 mm |
| Housing extent away from terminal row from shaft axis | 5.5 mm |
| Mounting datum to start of thread | 8.4 mm |
| Bushing | Ø9 mm, 5 mm long; ends at Z = 13.4 mm |
| Shaft | Ø6 mm envelope; tip at Z = 30 mm |

The housing is deliberately filled from Z = 0 to 8.4 mm. The actual rear housing is recessed and the front has smaller shoulders. This block conservatively fills those spaces; do not use its rear or front faces to infer the actual housing's contact surfaces. It is useful for reserving enclosure space, with the shaft and thread positions represented separately.

The drawing's 5.9 mm callout is not an axial body-depth dimension. Earlier conversational advice describing it that way was incorrect.

This is a nominal simplified model, not an exact replica or tolerance envelope. The specified shaft length is 30 ± 0.5 mm and its diameter is 6.0 +0/−0.1 mm. Thread grooves, knurling, split shaft, pins and mounting tabs are omitted. The smooth shaft fills the knurling envelope.

## Add it in KiCad

The PCB was open during model creation, so no board or library files were changed automatically.

1. In PCB Editor hover over RV1 and press **E**.
2. Open **3D Models**. Remove or disable the old PTV09A-1 model.
3. Add `${KIPRJMOD}/../../cad/PTV09A-6030U_envelope.step`.
4. Set scale to **1,1,1**, rotation to **0,0,0**, and offsets to **0,0,0 mm**.
5. Repeat for RV2, RV3 and RV4, then save the board.
6. Inspect the top and side views. The shaft should rise perpendicular to the PCB, centred on the footprint's shaft circle.

The model is aligned to the existing footprint's shaft centre: board coordinates X = 7 mm, Y = −2.5 mm relative to pin 1. STEP uses X = 7 mm, Y = +2.5 mm because KiCad's model Y direction is opposite its board Y direction. Z = 0 represents the PCB seating datum.

The board still uses a PTV09A-1 footprint. Alignment to its shaft centre does not validate its holes for PTV09A-6. Before finalizing the enclosure or manufacturing the board, compare the actual part's seating and shaft position with the PCB. A measured seating difference requires a matching model Z offset.

## Design the panel around the bushing

The panel must intersect the threaded region, **Z = 8.4 to 13.4 mm** relative to the assumed PCB seating datum. Reserve part of that 5 mm length for the supplied washer and nut rather than using it all for the panel.

The nut and washer are not included because their final Z positions depend on panel thickness:

- Washer: Ø15 ± 1 mm outside, Ø9.1 ± 0.3 mm inside, 0.4 mm thick.
- Nut: 11 ± 0.5 mm across flats, 2 ± 0.2 mm thick, M9 × 0.75 thread. Its corners extend beyond the across-flats dimension.

Use the actual hardware or add separate solids at the chosen panel position when checking neighboring parts and tool access. Size the panel hole for the Ø9 bushing plus the clearance appropriate to your printing process; check that clearance with a test print.

The shaft tip is at Z = 30 mm, not 30 mm beyond the end of the bushing. Add a separate model for the knob you choose.

## Regenerate

`build_pot_envelope.py` uses CadQuery to generate the STEP and re-imports it to check its solids and overall bounds. Run it in a Python environment with CadQuery installed. The resulting model spans X = 0.5…12.5, Y = −2.5…7.5 and Z = 0…30 mm.
