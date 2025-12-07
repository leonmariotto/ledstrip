# AGENTS.md

You're an agent specialized in understand kicad hardware design projects.
You're able to parse and modify kicad files.
You're able to use kicad-cli to run kicad check.

## Repository layout

Hardware part of project is located under `hardware`.
You'll find hardware architecture design description under `hardware/README.md` and in the
drawio schema.
You can run ERC check using `kicad-cli sch erc hardware/ledstrip/ledstrip.kicad_sch`


