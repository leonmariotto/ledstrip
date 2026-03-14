---
name: kicad-schematics-parsing
description: Parse KiCad schematics file in order to extract data or modify it.
---

# kicad-schematics-parsing

How to extract or modify data in KiCad schematics (`.kicad_sch`) without the GUI.

## Choose the interface first
- Use `kicad-cli` export plus direct `.kicad_sch` parsing for audits, field completeness, BOM/MPN checks, and low-level bulk edits.
- Use the KiCad schematic MCP server for semantic edits: add/remove components, inspect pins, add labels/wires/buses, connect pins, manage sheets, then save.
- Prefer plain parsing when correctness depends on raw file contents or when the MCP wrapper looks stale or buggy.
- Prefer MCP when the task is naturally schematic-aware, such as "connect U1 pin PB6 to R3 pin 1" or "add a resistor and label the net".

## Export structured data first
- Prefer exporting to XML (easy to parse) with `HOME=$PWD kicad-cli sch export netlist --format kicadxml
<schematic> -o /tmp/netlist.xml`.
- If the project uses custom libs, run in the project root so the project `sym-lib-table` is found. Setti
ng `HOME` to the repo avoids permission errors from KiCad trying to write under `/root`.
- For BOM-style field checks, `kicad-cli sch export bom <schematic> -o /tmp/bom.csv` can be simpler.
- Treat XML/BOM export as a first pass, not a source of truth for every custom field value. In some proje
cts the export preserves field names but drops populated per-symbol values needed for audits.

## Parsing tips (XML netlist)
- Components live under `<export><components><comp ref=...>`. Within each `<comp>` you have `<value>`, `<
footprint>`, `<description>`, `<fields>` (legacy fields) and `<property>` entries (modern properties).
- When reading a field/property, prefer `property` value, and fall back to `fields/field` if missing. Bot
h use the `name` attribute.
- Sheet hierarchy is exposed by `<sheetpath>` attributes if you need context per component.
- If expected custom values come back empty, switch to parsing the `.kicad_sch` directly before concluding
 the data is missing.

## Parsing tips (S-expression `.kicad_sch`)
- Each schematic is an S-expression rooted at `(kicad_sch ...)` with sections such as `(lib_symbols ...)`
 and many placed top-level `(symbol ...)` instances.
- Library symbols may appear under `(lib_symbols ...)`, but placed symbol instances are usually top-level `
(symbol ...)` blocks with `(property "Reference" "...")`, `(property "Value" "...")`, etc. Audit those in
stance blocks, not the library symbol definitions.
- Properties mirror what you see in XML export (`Distributor Link 1`, `Manufacturer Part Number`, etc.).
- Use an S-expression parser when available; if not, a small purpose-built parser for strings/lists is fin
e. Treat text as UTF-8.
- For edits, preserve formatting and numeric precision; KiCad is order-tolerant but stable ordering reduc
es churn.
- Ignore autosave or lock files such as `_autosave-*.kicad_sch` and `~*.lck` unless the user explicitly wa
nts them audited.

## MCP workflow
- Load the target schematic through the MCP server before making semantic edits.
- After loading, inspect with MCP methods such as component listing and pin lookup instead of recomputing symbol geometry yourself.
- For wire creation, prefer MCP connection helpers over hand-editing wires and junctions.
- Save through MCP, then validate with `kicad-cli sch export netlist` and ERC.
- If MCP fails on the real project, fall back immediately to plain parsing and `kicad-cli`; do not block on the wrapper.

## When plain parsing is better
- Auditing custom properties like `Distributor Link 1`, `Manufacturer Part Number`, and footprint completeness.
- Normalizing or bulk-editing per-symbol properties across many instances.
- Investigating hierarchy, formatting, or unusual constructs exactly as stored on disk.
- Working around MCP wrapper/API mismatches.

## Common queries
- Symbols missing a property: filter comps where `property["TargetProp"]` is empty but another property e
xists.
- Footprint completeness: ensure `Footprint`/`footprint` is set on every symbol unless intentionally excl
uded (`exclude_from_bom`/`exclude_from_board`).
- Link/MPN completeness: ensure `Distributor Link 1` and `Manufacturer Part Number` are filled for all pu
rchasing parts; headers/testpoints may be exempt.
- For link/MPN audits, check common misspellings seen in hand-edited projects too: `Distributor Link 1`, `
Disributor Link 1`, and `Ditributor Link 1`.
- Treat `Manufacturer Part Number` and `MPN` as equivalent by default; normalize field names before compar
ing.
- If a part has a distributor URL but no MPN field, you can often guess the MPN and manufacturer from the
 URL path. Example: Mouser links usually encode `/ProductDetail/<Manufacturer>/<MPN>`, DigiKey links often
 encode `/detail/<manufacturer>/<mpn>/...`, and vendor datasheet URLs may expose the MPN in the filename.

## Editing safely
- For small changes, edit the `.kicad_sch` S-expression directly: update `(property "Name" "Value")` or a
dd missing ones inside the symbol block.
- When adding properties, keep the same quoting and spacing as neighbors; avoid KiCad-specific tokens lik
e `~` unless already used.
- After edits, re-export with `kicad-cli sch export netlist --format kicadxml ...` and sanity-check count
s/fields.
- When backfilling procurement data, prefer updating the existing per-symbol instance properties instead of
 changing only library symbols.

## MCP patching notes
- Treat the MCP server as a thin wrapper around `kicad_sch_api`; if a tool fails with an attribute error, inspect the wrapper before blaming the schematic.
- Reproduce failures through the underlying Python API when possible. If `kicad_sch_api.Schematic.load(...)` works but the MCP tool fails, the bug is in the wrapper.
- In this environment, `title_block` is a `dict`, so wrapper code must use `schematic.title_block.get("title")`, not `schematic.title_block.title`.
- In this environment, some wrapper code assumed `schematic.lib_symbols` existed; use `schematic._data.get("lib_symbols", {})` if the public property is missing.
- `manage_power` is currently suspect here because the wrapper calls a missing `add_power_symbol` method. Use labels or direct file edits as fallback until patched.
- After patching the MCP server, verify by calling the exact MCP path again, not just the lower-level library.

## Checks
- ERC: `kicad-cli sch erc <schematic>` (may need project libs).
- If KiCad complains about missing global tables, copy/link required libs into the project `sym-lib-table
` or run with `HOME` set to a writable location inside the repo.
