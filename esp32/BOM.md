# Předběžný soupis materiálu (BOM) — interposer + ESP32

První průchod, sestavený z rozhodnutí zapsaných v
[HW-POZADAVKY.md](HW-POZADAVKY.md) a [ARCHITEKTURA.md](ARCHITEKTURA.md).
**Položky označené 🟡 OTEVŘENO nejsou finální** — nekupovat, dokud se
nerozhodne konkrétní typ/hodnota. Položky ✅ ROZHODNUTO jsou bezpečné
k objednání.

## Signálová cesta (32 analyzer/generátor kanálů)

| Položka | Množství | Účel | Stav |
|---|---|---|---|
| 6N137 (nebo HCPL-0630) optočlen | ~16× *(1 na vstupní kanál — viz níže)* | Rychlá galvanická izolace 5V/3.3V strany | 🟡 OTEVŘENO — souběží s druhou variantou níže, vybrat jednu |
| SN74CBT3245A (pin-kompat. za 74HC245) | 6× *(polovina z 12 stávajících)* | Alternativa: obousměrný FET switch místo 74HC245 na vstupních konektorech | 🟡 OTEVŘENO — **rozhodnout mezi optočleny a SN74CBT3245A, není důvod kupovat obojí na stejný účel** |
| 74HC4066 (4× analogový spínač) | 8× | Přepínání 5V/3.3V cesty per kanál (32 kanálů / 4 na čip) | ✅ ROZHODNUTO |
| PCF8575 (16bit I2C GPIO expandér) | 2× | Řízení 32 přepínacích bitů přes I2C (2 vodiče) | ✅ ROZHODNUTO |

## ESP32 + úložiště

| Položka | Množství | Účel | Stav |
|---|---|---|---|
| ESP32-WROOM-32 DevKit V1 (30 pin) | 1× | SoftAP + webserver + SPI most k FPGA | ✅ ROZHODNUTO |
| MicroSD modul (SPI, běžný breakout) | 1× | Trvalé úložiště presetů/záznamů | ✅ ROZHODNUTO (konkrétní modul neurčen, běžný SPI typ) |

## Napájení / baterie

| Položka | Množství | Účel | Stav |
|---|---|---|---|
| Li-ion/LiPo článek | 1× | Přenosné napájení | 🟡 OTEVŘENO — odhad spotřeby ~300 mA (uživatel), kapacita/rozměr článku z toho ještě neurčeny (viz odhad výdrže níže) |
| Step-up (boost) měnič | 1–2× | Ze napětí baterie na 3.3V (FPGA/ESP32) a 5V (74HC245/optočleny) | 🟡 OTEVŘENO — **nutno rozhodnout, jestli 2 nezávislé regulátory (boost→5V + samostatný 3.3V), nebo boost→5V a z něj LDO/buck na 3.3V** — architektura napájení zatím není vyřešená, ne jen konkrétní součástka |
| UVLO / battery protection obvod | 1× | Odpojení při vybité baterii, ochrana Li-ion článku | 🟡 OTEVŘENO — konkrétní IC nevybrán (např. DW01A+FS8205 nebo dedikovaný UVLO čip) |
| Nabíjecí obvod | 1× | Nabíjení přes jack, s odpojením | 🟡 OTEVŘENO — TP4056 jen jako orientační reference, ne finální volba |
| DC/barrel jack konektor | 1× | Fyzický nabíjecí konektor | 🟡 OTEVŘENO — typ/rozměr neurčen |

## Ostatní

| Položka | Množství | Účel | Stav |
|---|---|---|---|
| Vlastní PCB (interposer) | 1× | Nese vše výše, sedí na HUB75 ribbon konektorech | 🟡 OTEVŘENO — schéma/layout zatím nekresleny |
| Konektory pro ribbon kabely (pokud nejde použít stávající J1-J8 přímo) | ? | Fyzické spojení interposeru s hlavní deskou | 🟡 OTEVŘENO — záleží na mechanickém návrhu |

## Odhad výdrže baterie (při ~300 mA průměrné spotřeby)

Hrubý odhad, nepočítá účinnost step-up měniče (reálně tedy o něco méně):

| Kapacita článku | Výdrž (~300 mA) |
|---|---|
| 1000 mAh | ~3,3 h |
| 2000 mAh | ~6,6 h |
| 3000 mAh | ~10 h |

Se započtením ~85% účinnosti step-up měniče (typická hodnota) je
reálná výdrž o ~15 % nižší, než ukazuje tabulka.

## Co je potřeba rozhodnout, než se objedná zbytek

1. **Optočleny vs. SN74CBT3245A** — jedna cesta, ne obě, na stejný účel (vstupní kanály).
2. **Architektura napájení** (kolik regulátorů, jaké topologie) — teprve pak vybrat konkrétní step-up/UVLO/nabíjecí IC.
3. Kapacita baterie (závisí na odhadu spotřeby FPGA+ESP32+periferie — zatím nepočítáno).
4. Typ jacku a konkrétní SD modul (kosmetické rozhodnutí, nízké riziko, kdykoliv).
