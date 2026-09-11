# Architektura — logic analyzer / generátor (plán)

Shrnutí návrhu z diskuze, než se začne stavět hardware/firmware.
Zatím existuje jen frontend prototyp (`index.html`) s testovacími
daty — nic z tohohle ještě není implementované na hardwaru.

## Rozdělení práce mezi komponenty

```
tablet/PC (prohlížeč, tahle appka)
      |  WiFi (ESP32 v režimu SoftAP)
ESP32 (WROOM-32, levný) — webserver + WiFi <-> SPI most
      |  SPI
FPGA (Colorlight 5A-75B) — rychlé vzorkování/generování, SDRAM buffer
      |
HUB75 konektory (J1-J8, 56 pinů) — fyzické I/O
      |
MicroSD modul (SPI) na ESP32 — trvalé úložiště presetů/záznamů
```

- **ESP32** netuší nic o vzorkování/generování — jen přemosťuje WiFi
  ↔ SPI a servíruje statickou appku ze své flash.
- **FPGA** dělá skutečnou práci: vzorkovací hodiny (odvozené PLL z
  25 MHz, ne fixně), zápis/čtení SDRAM, řízení výstupních pinů.
- **MicroSD** (SPI modul, +4 piny na ESP32) — presety generátoru,
  uložené záznamy, přežije restart/výpadek napájení.

## Hardware — výstupy vs vstupy (HUB75 piny)

- **Výstupy (generátor): fungují bez úprav hned.** HUB75 piny jsou
  přes 74HC245 natvrdo výstupní, viz
  [../../docs/hub75-konektory-piny.md](../../docs/hub75-konektory-piny.md).
- **Vstupy (capture z vnějšího signálu): vyžadují výměnu 12×
  74HC245 → SN74CBT3245A** (pin-kompatibilní FET bus switch, viz
  chubby75 dokumentace) — hardwarový zásah, zatím neproveden.
- **Úroveň 3.3V vs 5V na výstupu:** přes 74HC245 vyjede vždy 5V
  (podstata level-translation čipu). 3.3V verze konkrétního pinu =
  buď odporový dělič na té jedné lince (jen pro slabé zátěže), nebo
  použít jiný, nebufferovaný FPGA pin (žádné volné momentálně nejsou
  — všechny ostatní piny desky jsou obsazené clk/led/btn/flash/sdram/eth).

## Vzorkovací/generovací hodiny

Neodvozovat pevně od 25 MHz palubního oscilátoru — FPGA PLL umí
vyšší (timing report ukazuje Fmax ~300+ MHz i pro triviální design).
Volba rychlosti = kompromis hloubka záznamu × rychlost, podle toho,
jak dlouhé okno reálně potřebujete zachytit/generovat.

## Plánované funkce appky (frontend už má základ, backend chybí)

1. **Terminálový vstup pro generátor** — `uart <text>`, `spi <hex
   bajty>`, `i2c <hex bajty>` — zakóduje se stejnou logikou, co dnes
   dekodéry používají obráceně.
2. **Trigger na vzor** (ne jen na hranu) — např. "spusť capture, až
   SPI pošle 0xAA".
3. **Loopback replay** — zaznamenaná komunikace se dá rovnou přehrát
   zpátky generátorem.
4. **Automatické měření** periody/duty cycle/šířky pulzu mezi kurzory.
5. **Presety** — pojmenované sekvence pro generátor, ukládané na SD.
6. **Roll mode** — živě se posouvající záznam pro pomalé signály,
   alternativa k jednorázovému trigger→capture.

## Co chybí, než se dá cokoliv z tohodle reálně vyzkoušet

- ESP32 firmware (SoftAP, webserver, SPI most, SD).
- FPGA strana (Verilog): SDRAM řadič, vzorkovací/generovací logika,
  SPI slave rozhraní k ESP32.
- Fyzické zapojení SD modulu a (později) výměna 74HC245 čipů pro
  vstupy.
- Propojení appky na reálný zdroj dat místo `generateTestData()`.
