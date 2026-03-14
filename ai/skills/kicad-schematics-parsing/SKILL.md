---
name: kicad-schematics-parsing
description: Parse KiCad schematics file in order to extract data or modify it.
---

# kicad-schematics-parsing

How to extract or modify data in KiCad schematics (`.kicad_sch`) without the GUI.

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

## Checks
- ERC: `kicad-cli sch erc <schematic>` (may need project libs).
- If KiCad complains about missing global tables, copy/link required libs into the project `sym-lib-table
` or run with `HOME` set to a writable location inside the repo.
