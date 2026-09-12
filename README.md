# test_verilog — Colorlight 5A-75B FPGA + ESP32 logic analyzer/generátor

Repo je rozdělené na tři nezávislé domény, každá se svým kódem a
dokumentací:

```
fpga/     Verilog design pro Colorlight 5A-75B (Lattice ECP5) —
          synth/sim/build skripty, JTAG pinout, board dokumentace.
          Viz fpga/README.md.

esp32/    Plánovaná architektura interposer desky + ESP32
          (WiFi most, SPI k FPGA, SD karta) — zatím jen dokumentace,
          firmware/HW se teprve staví. Viz esp32/ARCHITEKTURA.md.

webapp/   Logic analyzer / generátor — samostatná webová appka
          (index.html), zatím s testovacími daty, připravená na
          napojení na reálný ESP32 backend. Viz webapp/README.md.
```

Programátor FPGA (JTAG) je zatím STM32F103 s DirtyJTAG firmwarem —
zapojení a postup viz [fpga/docs/board-colorlight-5a75b-v8.md](fpga/docs/board-colorlight-5a75b-v8.md)
a [fpga/docs/workflow.md](fpga/docs/workflow.md).
