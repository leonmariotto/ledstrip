# Led Strip Project !

The goal here is to make a led strip that just work.
The layout is :
- hardware: kicad project to make the led strip controller board.
- cad: printable case for the controller + battery
- software: software used to control the led strip.
- ai: a setup to codex inside a docker with support for multiple AGENTS.md

## System requirements

- Must have a on/off switch
- Must have a battery properly scaled.
- Must provide a way to control color independently.
- Leds must be RGB with controllable intensity.
- Must provide a way to charge battery
- Must provide a way to program firmware.
- Must provide a way to program internal flash of MCU.
- Must be enclosed by a case.

## Part list
- https://opencircuit.fr/produit/analog-rgbw-led-strip-rgb-plus-warm-white-60
- Triangle-shape 3S battery with BMS integrated: https://www.amazon.fr/-/en/XINLANTECH-Rechargeable-18650-3s1p-Structure/dp/B0D1NHL2TF?crid=3UKSDUNZXJD5D&dib=eyJ2IjoiMSJ9.2kAS4RTT_2Vg5Q87rHNn6nUhXUT8zGuRABTSs_UrDTf9bOSZ8gR81oXCGuKBYzT-ARK0mytf4Zmdh-q67ISzf06tL6qj8S_YhDlNbtLJTaciIWVCLO6ghtoPslgk8t74uCp2UU1slJacCrMCu3EWuG0DE4qD27-FsxKFi4Xwl53Qwg3bbpy8Ixvebg5CsdjGX1nEl-hZM-Ur8H-madrxrLGr5RqIs81BftCQ3jFH0eHm63RT6Tu1IBGtVUmmS9P1NB2lMzVFmAcKharSQXNrWkAlVqnNcEswa_HGnV24cSc.HMNpHTsf-xSVbXEmZj1iyq6B1D1wcdYWJavxU8eNAV8&dib_tag=se&keywords=3s+11.1v+li+ion&qid=1765645024&sprefix=3s+11.1v+li+ion%2Caps%2C90&sr=8-7
- Flat shape 3S battery : https://www.amazon.fr/-/en/Replacement-Battery-Lansing-INR18650-3S-Speaker/dp/B092W4FK3K?crid=3UKSDUNZXJD5D&dib=eyJ2IjoiMSJ9.2kAS4RTT_2Vg5Q87rHNn6nUhXUT8zGuRABTSs_UrDTf9bOSZ8gR81oXCGuKBYzT-ARK0mytf4Zmdh-q67ISzf06tL6qj8S_YhDlNbtLJTaciIWVCLO6ghtoPslgk8t74uCp2UU1slJacCrMCu3EWuG0DE4qD27-FsxKFi4Xwl53Qwg3bbpy8Ixvebg5CsdjGX1nEl-hZM-Ur8H-madrxrLGr5RqIs81BftCQ3jFH0eHm63RT6Tu1IBGtVUmmS9P1NB2lMzVFmAcKharSQXNrWkAlVqnNcEswa_HGnV24cSc.HMNpHTsf-xSVbXEmZj1iyq6B1D1wcdYWJavxU8eNAV8&dib_tag=se&keywords=3s+11.1v+li+ion&qid=1765645024&sprefix=3s+11.1v+li+ion%2Caps%2C90&sr=8-8
