# HW požadavky — interposer deska pro Colorlight 5A-75B

Zápis nápadů z diskuze, než se cokoliv navrhuje/objednává. Nic z
tohohle není zatím navržené ani ověřené hodnotami součástek —
je to seznam požadavků a otevřených otázek.

## Koncept

Vlastní deska ("interposer"), která se **nasadí na HUB75 ribbon
konektory** (J1-J8) místo přímého připojení LED panelů. Řeší:

1. **Rozdělení pinů na výstupní a vstupní skupinu** — ne všech 12×
   74HC245 se mění. **Jen polovina** se odpojí/vyjme a nahradí
   (nebo přemostí jumperem), zbytek zůstává jako dnes (natvrdo
   výstupní, funguje beze změny).
2. **Galvanické oddělení vstupní strany optočleny** — místo (nebo
   navíc k) SN74CBT3245A swapu. Optočlen elektricky **odděluje**
   5V HUB75 stranu od FPGA 3.3V strany — žádné přímé napěťové
   spojení, tedy **cíl "nikdy to nespálit" je tímhle splněný
   spolehlivěji** než jen level-shift čipem.
3. **ESP32 přímo na téhle desce** — ne na samostatném prototypu,
   rovnou součást interposeru.

## Otevřené otázky k tomuhle bodu

- Kolik z 8 HUB75 konektorů bude výstupních vs. vstupních? (Zatím
  neurčeno — "polovinu 245" naznačuje 6 čipů/6 kanálů datových
  linek na jednu stranu, 6 na druhou, ale přesné rozdělení podle
  konektorů J1-J8 potřeba ještě navrhnout.)
- Typ optočlenu — rychlost (SPI/vzorkovací hodiny budou v jednotkách
  MHz, běžné levné optočleny typu PC817 na to nestačí, potřeba
  rychlé, např. 6N137 / HCPL-0630 řady nebo podobné — **ověřit, co
  přesně je na skladě**).
- Přesné schéma zapojení DIR/OE na vyměněné straně (viz
  [ARCHITEKTURA.md](ARCHITEKTURA.md) — DIR na SN74CBT3245A neexistuje,
  jen OE).

## Napájení

- **Zdroj:** Li-ion/LiPo baterie (přenosné použití, bez nutnosti
  externího napájení v terénu).
- **Step-up (boost) měnič** z napětí baterie na potřebné napájecí
  úrovně (3.3V pro FPGA/ESP32, případně 5V pro 74HC245/optočleny).
- **Podpěťová ochrana (UVLO / low-voltage disconnect)** — automatické
  odpojení zátěže při vybité baterii, ochrana Li-ion článku před
  hlubokým vybitím.
- **Nabíjení přes jack** (DC/barrel jack, přesná specifikace
  konektoru a nabíjecího proudu zatím neurčena) — **s vlastním
  odpojením** (buď odpojení zátěže během nabíjení, nebo standardní
  nabíjecí obvod s ochranou proti přebití — např. řešení podobné
  TP4056, ale to je jen orientační, ne finální volba).

## Součástky — co ověřit na skladě

- SMD optočleny — **uživatel má nějaké, typ/rychlost neověřena.**
- Obecné SMD součástky (rezistory, kondenzátory pro obvyklé hodnoty)
  — sklad neinventarizován.

## Co chybí, než se dá cokoliv navrhnout do schématu

1. Rozhodnout přesné rozdělení 8 konektorů na vstupní/výstupní skupinu.
2. Zjistit skutečný typ dostupných optočlenů (rychlost musí stačit
   na zamýšlené vzorkovací frekvence).
3. Zvolit step-up měnič a UVLO obvod (konkrétní součástky).
4. Zvolit nabíjecí obvod a typ jacku.
5. Teprve pak má smysl kreslit schéma/PCB.
