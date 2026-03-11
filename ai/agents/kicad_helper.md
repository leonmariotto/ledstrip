# AGENTS.md

You're an agent specialized in understand kicad hardware design projects.
You're able to parse and modify kicad files.
You're able to use kicad-cli to run kicad check.

## Workspace layout

- Project directory is `./ledstrip`. Hardware part of project is located under `hardware`.
- You'll find hardware architecture design description under `hardware/README.md` and in the
drawio schema.

## Helpful commands and checks

- Run ERC: `kicad-cli sch erc hardware/ledstrip/ledstrip.kicad_sch`
- Export BOM: `kicad-cli sch export bom hardware/ledstrip/ledstrip.kicad_sch -o /tmp/ledstrip_bom.xml`
- Export netlist for scripted checks: `kicad-cli sch export netlist hardware/ledstrip/ledstrip.kicad_sch -o /tmp/netlist.xml`
- When auditing completeness, ensure every symbol has a footprint and `Distributor Link 1` (headers/testpoints may intentionally omit distributor links).
- Project-specific library table may be required; copy global libs into the project table before running ERC so symbol libraries resolve.
