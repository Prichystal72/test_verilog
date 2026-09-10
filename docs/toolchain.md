# Toolchain: OSS CAD Suite

Použitý toolchain je [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build)
— balíček obsahující Yosys, nextpnr, Project Trellis (ECP5), Icarus
Verilog, Verilator, GTKWave a openFPGALoader v jedné instalaci.

- **Instalace:** `C:\oss-cad-suite`
- **Verze:** `20260910` (viz `C:\oss-cad-suite\VERSION`)
- **Není** balené s tímto repem — je to samostatná instalace na tomto
  počítači, kterou je potřeba mít i na jakémkoliv jiném stroji, kam se
  repo přenese.

## PATH

Nástroje vyžadují na PATH jak `bin`, tak `lib` (DLL závislosti), jinak
padají na chybu "DLL not found" (Windows exit code `0xC0000135`).

Na tomto stroji je PATH nastaven **trvale** (uživatelská proměnná
prostředí), přidáno:

```
C:\oss-cad-suite\bin
C:\oss-cad-suite\lib
```

Po nastavení je potřeba **otevřít nový terminál** (staré terminály/procesy
mají PATH nakešovaný ze startu).

### Na novém stroji

Buď zopakuj trvalé nastavení PATH (`Ovládací panely -> Systém -> Upravit
proměnné prostředí` nebo `[Environment]::SetEnvironmentVariable(...)`),
nebo si vždy před prací načti oficiální skript dodávaný s instalací:

```powershell
. C:\oss-cad-suite\environment.ps1
```

(nastaví PATH jen pro aktuální relaci terminálu, nic netrvalého).

## Použité nástroje

| Nástroj | Účel | Ověřeno funkční |
|---|---|---|
| `yosys.exe` | Verilog → syntéza → JSON netlist | ✅ |
| `nextpnr-ecp5.exe` | Place & route pro ECP5 | ✅ |
| `ecppack.exe` | Config → `.bit` bitstream | ✅ (se zvláštností, viz [toolchain-notes.md](toolchain-notes.md)) |
| `iverilog.exe` / `vvp.exe` | Simulace | ✅ |
| `gtkwave.exe` | Prohlížení waveforem (`.vcd`) | nevyzkoušeno graficky (GUI), spustitelný |
| `openFPGALoader.exe` | Nahrání bitstreamu do HW | ❌ padá, viz notes; navíc nemáme HW k testu |
| `verilator` | Alternativní/rychlejší simulátor, lint | k dispozici, nevyužito v tomto testu |
