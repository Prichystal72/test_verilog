# Workflow

## 1. Simulace (bez hardwaru) — hlavní způsob vývoje bez desky

```powershell
powershell -ExecutionPolicy Bypass -File scripts\sim.ps1
```

Co dělá:
1. `iverilog` zkompiluje `rtl/blink.v` + `tb/blink_tb.v` do `build\blink_tb.vvp`.
2. `vvp` simulaci spustí, testbench sám vyhodnotí, jestli LED přepnula
   správně po resetu a po jednom plném "blik" cyklu, a vypíše
   `TEST PASSED` / `TEST FAILED`.
3. Vytvoří se `build\blink_tb.vcd` (waveform).

Prohlédnutí waveformy v GTKWave:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\sim.ps1 -Wave
```

### Přidání vlastního designu k otestování

1. Nový modul do `rtl/`.
2. Testbench do `tb/` (viz `tb/blink_tb.v` jako vzor — self-checking,
   s `$display("TEST PASSED"/"TEST FAILED")` a timeoutem).
3. Uprav `scripts/sim.ps1` (seznam souborů pro `iverilog`) nebo si udělej
   kopii skriptu pro nový design.

## 2. Plný build (synth → PnR → bitstream), stále bez hardwaru

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build.ps1
```

Co dělá (viz [docs/toolchain-notes.md](toolchain-notes.md) pro
`ecppack` quirk):
1. `yosys -p "read_verilog ...; synth_ecp5 -top blink -json ..."`
   → syntéza do JSON netlistu.
2. `nextpnr-ecp5 --json ... --lpf constraints\colorlight_5a75b_v8.lpf
   --25k --package CABGA256 --speed 6 --textcfg ...`
   → place & route s constraints pro v8.0 desku, vypíše i timing report
   (v aktuálním designu vychází Fmax ~315 MHz, tedy s velkou rezervou
   nad požadovaných 25 MHz).
3. `ecppack ... blink.bit` → finální bitstream.

Výstup: `build\blink.bit`. **Nikam se nenahrává** — tenhle krok slouží
jen k ověření, že design projde celým tokem bez chyb a že constraints
(piny) odpovídají existující dokumentaci desky.

## 3. Nahrání na hardware (ověřeno funkční)

Sestava: STM32F103 Blue Pill s nahraným [DirtyJTAG](https://github.com/jeanthom/DirtyJTAG)
firmwarem jako JTAG adaptér, WinUSB driver nastavený přes Zadig. Zapojení
pinů viz [docs/board-colorlight-5a75b-v8.md](board-colorlight-5a75b-v8.md#zapojení-stm32f103-dirtyjtag-firmware-na-tento-header).

```powershell
cd C:\oss-cad-suite
. .\environment.ps1              # nutné, viz toolchain-notes.md bod 3
cd C:\Users\prich\Documents\Arduino\test_verilog
openFPGALoader.exe -c dirtyJtag --detect        # ověření JTAG chainu (IDCODE LFE5U-25F)
openFPGALoader.exe -c dirtyJtag build\blink.bit # nahrání do SRAM (dočasné, do vypnutí)
```

Po nahrání `DATA_LED` na desce viditelně bliká cca 2× za sekundu (design
dělí 25 MHz na bit 23 čítače) — **potvrzeno na reálném HW**.

Poznámka: `-b colorlight-5a-75b` (board profil místo `-c dirtyJtag`) jsme
nezkoušeli, `-c dirtyJtag` funguje spolehlivě a je explicitní o použitém
adaptéru.
