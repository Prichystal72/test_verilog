# Zjištěné zvláštnosti toolchainu (Windows)

Poznámky z reálného odzkoušení na tomto stroji (Windows 10, OSS CAD Suite
`20260910`), aby se příště neztrácel čas laděním stejné věci.

## 1. `ecppack.exe` padá při ukončování procesu (heap corruption)

**Příznak:** `ecppack.exe config.config out.bit` vypíše normální průběh,
korektně zapíše `out.bit`, ale proces skončí s exit kódem
`-1073740940` (`0xC0000374`, `STATUS_HEAP_CORRUPTION`) místo `0`.

**Ověřeno opakovaně** (3× čistý běh) — soubor je pokaždé validní:
hlavička `.bit` souboru obsahuje správný `Part: LFE5U-25F-6CABGA256` a
velikost odpovídá očekávání (~580 kB pro tento malý design).

**Dopad:** skript, který slepě kontroluje `$LASTEXITCODE -eq 0`, zahlásí
selhání, i když bitstream je v pořádku.

**Řešení použité v [scripts/build.ps1](../scripts/build.ps1):** úspěch se
ověřuje existencí a nenulovou velikostí výstupního `.bit` souboru, ne
exit kódem. Nenulový exit kód z `ecppack` se jen zaloguje jako "known
benign crash-on-exit".

**Pokud budeš aktualizovat OSS CAD Suite:** zkontroluj, jestli novější
verze tohle už neopravila (pak lze `build.ps1` zase zpřísnit na kontrolu
exit kódu).

## 2. `openFPGALoader.exe` "nejde spustit" — vyřešeno, viz bod 3

Dřívější pozorování na jiné instalaci OSS CAD Suite (`ENTRYPOINT_NOT_FOUND`,
`0xC0000139`) se na aktuální instalaci (`C:\oss-cad-suite`, staženo
2026-09) neprojevilo. Co se skutečně objevilo a jak se to vyřešilo, viz
bod 3 níže (`environment.ps1`). Pro flashování na reálný hardware navíc
je potřeba WinUSB driver přes Zadig pro USB zařízení JTAG adaptéru
(DirtyJTAG `0x1209:c0ca`) — bez něj `openFPGALoader` zařízení nenajde.

**Ověřeno funkční:** STM32F103 Blue Pill s DirtyJTAG firmwarem,
`openFPGALoader.exe -c dirtyJtag build\blink.bit` úspěšně naprogramoval
SRAM FPGA na Colorlight 5A-75B v8.0 (LED viditelně blikala). Zapojení viz
[docs/board-colorlight-5a75b-v8.md](board-colorlight-5a75b-v8.md).

## 3. `openFPGALoader.exe` padá s ACCESS_VIOLATION, pokud chybí `environment.ps1`

**Příznak:** i s `C:\oss-cad-suite\bin` v PATH `openFPGALoader.exe --help`
spadne okamžitě s `-1073741819` (`0xC0000005`, `STATUS_ACCESS_VIOLATION`),
bez jakéhokoliv výstupu — dřív, než vypíše cokoliv.

**Řešení:** nestačí mít jen `bin`+`lib` v PATH, je potřeba nejdřív
sourcovat `C:\oss-cad-suite\environment.ps1` (nastaví další proměnné, ne
jen PATH):

```powershell
cd C:\oss-cad-suite
. .\environment.ps1
openFPGALoader.exe --help   # teď funguje normálně
```

Po sourcování `--list-cables` správně vypíše i `dirtyJtag` (`0x1209:c0ca`).

Toto vyžaduje spustit v každém novém shellu / na začátku skriptu, který
`openFPGALoader` volá — zvážit doplnění do `build.ps1`/nového
`flash.ps1`, až se bude řešit reálné nahrávání.

## 4. Registry PATH změna se v aktuálním terminálu neprojeví hned

`[Environment]::SetEnvironmentVariable("Path", ..., "User")` zapíše do
registru, ale **již běžící procesy** (včetně terminálu, ve kterém právě
pracuješ) mají PATH načtený ze startu a nezmění se samo. Je potřeba
otevřít nový terminál/proces, aby změnu zdědil.
