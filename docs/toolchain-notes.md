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

## 2. `openFPGALoader.exe` nejde vůbec spustit

**Příznak:** `openFPGALoader.exe --Version` (i bez parametrů) padá s exit
kódem `-1073741511` (`0xC0000139`, `STATUS_ENTRYPOINT_NOT_FOUND`) — tedy
chybí exportovaná funkce v nějaké DLL, typicky nesoulad verzí mezi
`.exe` a knihovnou (např. libusb/FTDI/zadig komponenty).

**Dopad:** zatím nejde touhle instalací nic naprogramovat, i kdyby HW byl
po ruce.

**Nebylo dál řešeno**, protože fyzický hardware stejně nemáme — needitovat
teď. Až deska dorazí:
1. Zkusit přeinstalovat/aktualizovat OSS CAD Suite (možná poškozený/
   částečný archiv jen u této jedné binárky).
2. Zkontrolovat, že `libusb`/ovladač (WinUSB/libusbK přes Zadig) je pro
   JTAG/UART adaptér na desce nastavený.
3. Alternativa: nahrát bitstream jiným nástrojem (např. přes OpenOCD,
   nebo JTAG přes jiný existující nástroj), pokud `openFPGALoader` zůstane
   nefunkční.

## 3. Registry PATH změna se v aktuálním terminálu neprojeví hned

`[Environment]::SetEnvironmentVariable("Path", ..., "User")` zapíše do
registru, ale **již běžící procesy** (včetně terminálu, ve kterém právě
pracuješ) mají PATH načtený ze startu a nezmění se samo. Je potřeba
otevřít nový terminál/proces, aby změnu zdědil.
