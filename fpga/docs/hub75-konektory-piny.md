# HUB75 konektory (J1–J8) — fyzické propojení na FPGA piny

Colorlight 5A-75B v8.0. Piny konektoru číslované 1–16 (standardní HUB75
pořadí), namapované na FPGA piny (LFE5U-25F-6BG256C), bez ohledu na
původní RGB/HUB75 význam signálů.

Zdroj dat: `litex_boards` (`litex_boards/platforms/colorlight_5a_75b.py`,
`_connectors_v8_0`), ověřeno proti [chubby75 hardware_V8.0.md](https://github.com/q3k/chubby75/blob/master/5a-75b/hardware_V8.0.md).

## Sdílené piny (stejné na všech 8 konektorech)

| Konektor pin # | FPGA pin | Poznámka |
|---|---|---|
| 4  | — | GND, žádný FPGA pin |
| 8  | N4 | |
| 9  | N5 | |
| 10 | N3 | |
| 11 | P3 | |
| 12 | P4 | |
| 13 | M3 | |
| 14 | N1 | |
| 15 | M4 | |
| 16 | — | GND, žádný FPGA pin |

8 skutečných FPGA pinů sdílených napříč všemi konektory (piny 4 a 16 jsou GND, nepočítají se).

## Unikátní piny (jiné na každém konektoru)

| Konektor pin # | J1 | J2 | J3 | J4 | J5 | J6 | J7 | J8 |
|---|---|---|---|---|---|---|---|---|
| 1 | C4 | F1 | B1 | P5 | T13 | R15 | G16 | D16 |
| 2 | D4 | F2 | C2 | R3 | R12 | T15 | H14 | E15 |
| 3 | E4 | G2 | C1 | P2 | R13 | P13 | G15 | C16 |
| 5 | D3 | G1 | D1 | R2 | R14 | P14 | F15 | B16 |
| 6 | F5 | H2 | E2 | T2 | T14 | N14 | F16 | C15 |
| 7 | E3 | H3 | E1 | N6 | P12 | H15 | E16 | B15 |

6 unikátních pinů × 8 konektorů = 48 unikátních FPGA pinů.

## Celkem

48 unikátních + 8 sdílených = **56 FPGA pinů** použitých pro všech 8
HUB75 konektorů dohromady. (Vlastní výpočet, nikde takhle explicitně
neuvedeno ve zdrojích.)

## Poznámka k 74HC245 level shifterům

Všech 12× `74HC245T` na desce je zapojeno **jednosměrně** (DIR pin
natvrdo, ne řízený FPGA) — HUB75 protokol je čistě výstupní, žádný
signál neteče zpátky. Pro obousměrné/vstupní použití těchto pinů by
bylo nutné fyzicky vyměnit čipy za pin-kompatibilní `SN74CBT3245A`
(FET bus switch). Přesné zapojení DIR pinu není ve zdrojích
zdokumentované (žádné schéma není veřejně dostupné, jen
reverse-engineered piny).

⚠️ **ECP5 FPGA piny nejsou 5V tolerantní** — HUB75 strana běží na 5V.
Cokoliv se na tyhle piny přivede zpět bez správného ošetření může FPGA
poškodit.
