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

## Kanálový rozpočet (určeno)

**16 vstupních + 16 výstupních = 32 datových kanálů celkem.** Z 56
dostupných HUB75 pinů (viz
[../../docs/hub75-konektory-piny.md](../../docs/hub75-konektory-piny.md))
zbývá 24 volných — dost rezervy na SPI/SD linky k ESP32 a další
řídicí signály. Rozdělení 32 kanálů nemusí kopírovat hranice
konektorů J1-J8 (na interposer desce se stejně vše přesměruje přes
vlastní optočleny/přepínače) — je to skutečně volný výběr 16+16 z
dostupných pinů.

## Přepínání úrovně/směru per kanál

Aplikace dnes má u každého kanálu jen **popisek** 5V/3.3V (viz
`tools/logic-analyzer/index.html`) — žádné skutečné řízení HW. Pro
32 kanálů, kde by se úroveň/směr měl dát reálně přepínat, dává smysl:

- **Analogový přepínač na kanál** (např. `74HC4066` — 4× obousměrný
  spínač na jednom čipu, 8 čipů pokryje 32 kanálů), který volí mezi
  "přímá 3.3V cesta" a "cesta přes level shift/optočlen na 5V".
- **Řízení přes I2C GPIO expandér**, ne přímo z FPGA/ESP32 pinů — např.
  2× `PCF8575` (16bit každý) dá dohromady 32 řídicích bitů po **jen
  2 vodičích (I2C)**. Bez tohohle by 32 přepínačů žralo 32 pinů
  navíc, což by smysl nedávalo.
- Nutno ověřit, jestli `74HC4066` (nebo obdoba) zvládne rychlosti,
  co plánujeme (jednotky MHz) — u analogových CMOS spínačů bývá
  limitující faktor R_on × C_load, ne přímo frekvence, ale **ověřit
  konkrétní datasheet**, než se to navrhne do schématu.

## Otevřené otázky k tomuhle bodu

- Typ optočlenu — **PC817 potvrzeně nestačí** (mezní frekvence
  ~80 kHz, rise/fall ~18 µs — na I2C 100 kHz těsně pod limitem, na
  SPI/MHz vzorkování zcela nedostatečné). **Rozhodnuto: dokoupit
  6N137** (desítky Mbit/s), na skladě je jen PC817.
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

1. Vybrat, kterých 16+16 konkrétních pinů z 56 dostupných použít.
2. Zjistit skutečný typ dostupných optočlenů (rychlost musí stačit
   na zamýšlené vzorkovací frekvence).
3. Ověřit rychlost `74HC4066` (nebo alternativy) pro přepínání úrovně
   per kanál, a dostupnost `PCF8575`/obdoby pro I2C řízení 32 bitů.
4. Zvolit step-up měnič a UVLO obvod (konkrétní součástky).
5. Zvolit nabíjecí obvod a typ jacku.
6. Teprve pak má smysl kreslit schéma/PCB.
