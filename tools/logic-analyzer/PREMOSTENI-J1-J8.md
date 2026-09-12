# Přemostění 74HC245 na J1 a J8 (pilotní konektory)

Vizuální verze (schéma + tabulky): https://claude.ai/code/artifact/976d9a5f-2b7d-4c48-9fde-8d94864befde

Cíl: dostat na J1 a J8 **čisté 3,3V signály přímo z FPGA**, bez
průchodu přes 74HC245 (ten by je natvrdo vytáhl na 5V, viz
[HW-POZADAVKY.md](HW-POZADAVKY.md)). Řešení: **vyjmout příslušný
74HC245 a nahradit ho drátovým jumperem** mezi FPGA-stranou a
konektor-stranou pro každý ze 6 unikátních datových pinů.

⚠️ Nemáme reálné schéma desky (jen piny z reverse-engineeringu, viz
[../../docs/hub75-konektory-piny.md](../../docs/hub75-konektory-piny.md)) —
**nevíme jistě fyzické rozmístění pinů 74HC245 pouzdra na desce ani
přesně to, který konkrétní čip ze 12 obsluhuje který konektor.** Než
se pájí, ověřit multimetrem (kontinuita) na reálné desce, že se
jumperem fakt propojí FPGA pin ↔ konektor pin, ne něco jiného.

## J1 — vstupní pilotní konektor (1. ze 4 vstupních: J1-J4)

| Funkce | FPGA pin (ball) | J1 konektor pin | Poznámka |
|---|---|---|---|
| "R0" pozice | C4 | 1 | |
| "G0" pozice | D4 | 2 | |
| "B0" pozice | E4 | 3 | |
| — | — | 4 | GND, nepřipojovat na jumper |
| "R1" pozice | D3 | 5 | |
| "G1" pozice | F5 | 6 | |
| "B1" pozice | E3 | 7 | |
| — | — | 16 | GND, nepřipojovat na jumper |

Těchto 6 pinů (1,2,3,5,6,7) = 6 z 24 vstupních kanálů, jednotlivě
půjdou přes TVS clamp → komparátor s nastavitelným prahem → 6N137
izolace → FPGA (viz architektura v HW-POZADAVKY.md). Přemostění zatím
řeší **jen** cestu 74HC245-bypass, ne celý vstupní řetězec.

**J1 sdílené piny (8-15) — ESP32↔FPGA komunikace, viz
[ESP32-J1-PROPOJENI.md](ESP32-J1-PROPOJENI.md)** — samostatný účel,
jiné piny než výše uvedené unikátní 1,2,3,5,6,7.

## J8 — výstupní pilotní konektor (1. ze 4 výstupních: J5-J8)

| Funkce | FPGA pin (ball) | J8 konektor pin | Poznámka |
|---|---|---|---|
| "R0" pozice | D16 | 1 | |
| "G0" pozice | E15 | 2 | |
| "B0" pozice | C16 | 3 | |
| — | — | 4 | GND, nepřipojovat na jumper |
| "R1" pozice | B16 | 5 | |
| "G1" pozice | C15 | 6 | |
| "B1" pozice | B15 | 7 | |
| — | — | 16 | GND, nepřipojovat na jumper |

Těchto 6 pinů = 6 z 24 výstupních kanálů, půjdou přes FPGA → 6N137
izolace → MOSFET → pull-up (3,3V default / externí svorka do 24V) —
viz architektura v HW-POZADAVKY.md.

## Postup pájení (obecně, pro oba konektory)

1. Identifikovat na desce 74HC245, co obsluhuje daný konektor (podle
   umístění blízko konektoru — ověřit, ne předpokládat).
2. Vypájet čip (nebo aspoň nadzvednout/přestřihnout jeho piny, ať
   neinterferuje).
3. Najít na desce, které dva pady (FPGA-strana vs. konektor-strana)
   odpovídají stejnému signálu (podle tabulky výše) a propojit
   drátovým jumperem.
4. Multimetrem ověřit kontinuitu FPGA pin ↔ konektor pin, a **naopak
   žádnou kontinuitu na 5V rail** (aby se potvrdilo, že už signál
   neteče přes starý 5V okruh).
5. Až pak pokračovat s další vrstvou (TVS/komparátor pro vstup,
   6N137+MOSFET pro výstup).

## Zbývajících 6 konektorů (J2-J4 vstupy, J5-J7 výstupy)

Stejný postup, až se ověří, že J1/J8 pilot funguje. Nekreslit zvlášť,
dokud se nepotvrdí správnost na téhle dvojici.
