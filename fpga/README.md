# test_verilog — Colorlight 5A-75B (ECP5) toolchain sandbox

Testovací repo pro ověření open-source FPGA toolchainu (Yosys / nextpnr /
Project Trellis) pro desku **Colorlight 5A-75B, revize v8.0**, bez fyzického
přístupu k hardwaru. Vše se dá ověřit simulací a "suchým během" celého
syntézního flow — bitstream se sestaví, ale nikam se nenahrává.

## Obsah repa

```
rtl/                 zdrojový Verilog (návrh)
  blink.v            testovací blikací design pro onboard LED
tb/                   testbenche pro simulaci
  blink_tb.v          self-checking testbench pro blink.v
constraints/          fyzické constraints (piny) pro konkrétní desku
  colorlight_5a75b_v8.lpf
scripts/               PowerShell skripty pro celý flow
  sim.ps1             simulace (Icarus Verilog)
  build.ps1           synth -> place&route -> bitstream (bez nahrávání)
  flash.ps1           nahrání bitstreamu na HW přes JTAG (openFPGALoader)
build/                 (negitované) výstupy skriptů
docs/
  board-colorlight-5a75b-v8.md   info o desce a piny
  toolchain.md                    co je nainstalováno a jak se spouští
  toolchain-notes.md              zjištěné patálie/quirky nástrojů
  workflow.md                     jak dál pracovat (sim / build / flash)
  lpf-pin-constraints.md          jak fungují .lpf soubory a volba režimu pinů
```

## Rychlý start

Nástroje (OSS CAD Suite) jsou nainstalované v `C:\oss-cad-suite` a přidané do
uživatelského PATH (`bin` + `lib`). Otevři **nový** terminál, ať PATH platí,
a spusť:

```powershell
# simulace testbenche (bez HW)
powershell -ExecutionPolicy Bypass -File scripts\sim.ps1
powershell -ExecutionPolicy Bypass -File scripts\sim.ps1 -Wave   # + GTKWave

# plný build: synth + place&route + bitstream (bez HW, nikam se nenahrává)
powershell -ExecutionPolicy Bypass -File scripts\build.ps1

# nahrání na reálný hardware (STM32 Blue Pill + DirtyJTAG), SRAM = dočasné
powershell -ExecutionPolicy Bypass -File scripts\flash.ps1
powershell -ExecutionPolicy Bypass -File scripts\flash.ps1 -Detect   # jen ověření JTAG chainu
```

Detaily viz [docs/workflow.md](docs/workflow.md).

## Stav

- ✅ Simulace (`iverilog` + `vvp`) funguje a testbench prochází.
- ✅ Plný build (`yosys` → `nextpnr-ecp5` → `ecppack`) proběhne a vyprodukuje
  platný `.bit` soubor cílený na `LFE5U-25F-6CABGA256`.
- ✅ Nahrání na reálný hardware (`openFPGALoader` přes STM32F103 Blue Pill s
  DirtyJTAG firmwarem, `-c dirtyJtag`) funguje — `blink.bit` nahraný do SRAM
  FPGA, `DATA_LED` na desce viditelně bliká. Piny a zapojení viz
  [docs/board-colorlight-5a75b-v8.md](docs/board-colorlight-5a75b-v8.md),
  postřehy k `openFPGALoader.exe` (nutnost sourcovat `environment.ps1`) viz
  [docs/toolchain-notes.md](docs/toolchain-notes.md).
