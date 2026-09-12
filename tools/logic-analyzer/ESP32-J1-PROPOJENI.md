# ESP32 ↔ FPGA přes J1 sdílené piny (SPI-A)

Vizuální verze (schéma + tabulky): https://claude.ai/code/artifact/976d9a5f-2b7d-4c48-9fde-8d94864befde

Fyzické spojení ESP32 (WROOM-32, 30pin DevKit) s FPGA jde přes **J1
konektor, sdílené piny (pozice 8-15)** — ty jsou stejné/společné na
všech 8 HUB75 konektorech (viz
[../../docs/hub75-konektory-piny.md](../../docs/hub75-konektory-piny.md)),
takže J1 je jen fyzický přístupový bod, ne že by signál patřil jen
jemu.

⚠️ Nevíme jistě, jestli těchto 8 sdílených pinů jde přes **vlastní**
74HC245 (pak nutno přemostit stejně jako u
[PREMOSTENI-J1-J8.md](PREMOSTENI-J1-J8.md)), nebo jinak — ověřit
multimetrem na reálné desce, ne předpokládat.

## Mapování pinů

| Signál | ESP32 GPIO | J1 konektor pin | FPGA pin (ball) |
|---|---|---|---|
| SCK  | 14 | 8  | N4 |
| MOSI | 27 | 9  | N5 |
| MISO | 34 *(input-only, sedí pro MISO)* | 10 | N3 |
| CS   | 26 | 11 | P3 |
| — *(rezerva, nezapojeno)* | — | 12 | P4 |
| — *(rezerva, nezapojeno)* | — | 13 | M3 |
| — *(rezerva, nezapojeno)* | — | 14 | N1 |
| — *(rezerva, nezapojeno)* | — | 15 | M4 |
| GND  | GND | 4 nebo 16 | — |

Piny 12-15 (J1) zůstávají volné — rezerva na budoucí rozšíření
(např. interrupt/reset linka k FPGA), zatím nezapojovat.

## Napájení

ESP32 má **vlastní USB napájení** (5V), nezávislé na FPGA desce —
stejně jako STM32 dosud. Sdílená GND mezi ESP32 a FPGA je **povinná**
(přes J1 pin 4/16), i když napájení je oddělené — stejné pravidlo,
jaké platilo u STM32/DirtyJTAG zapojení.

## Co zůstává mimo tenhle soubor

- **JTAG programování FPGA** — pořád přes STM32/DirtyJTAG, beze
  změny, neřeší se tady (viz
  [../../docs/board-colorlight-5a75b-v8.md](../../docs/board-colorlight-5a75b-v8.md)).
- **SD karta (SPI-B)** — samostatné ESP32 piny (VSPI: 18/23/19/5, viz
  [HW-POZADAVKY.md](HW-POZADAVKY.md)), nesouvisí s J1/FPGA vůbec.
- **74HC245 na J1 unikátních pinech (1,2,3,5,6,7)** — to je vstupní
  kanálová cesta, řešeno v `PREMOSTENI-J1-J8.md`, ne v tomhle souboru
  (ten je jen o sdílených pinech 8-15 pro ESP32 komunikaci).
