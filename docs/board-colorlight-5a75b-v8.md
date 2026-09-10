# Deska: Colorlight 5A-75B, revize v8.0

Levná LED-panel "receiving card" deska, oblíbená jako laciný ECP5 FPGA dev
kit (podobně jako Colorlight i5/i9). My fyzicky desku **nemáme** — tahle
dokumentace je pro budoucí použití, až HW dorazí.

## Čip

| | |
|---|---|
| FPGA | Lattice ECP5, **LFE5U-25F-6BG256C** |
| LUT | 25k |
| Balení | CABGA256 (256-ball, **ne** CABGA381!) |
| Speed grade | 6 |

⚠️ Pozor na revize desky — starší v6.1/v7.0 používají větší balení
CABGA381 a jiný pinout. Než cokoliv flashneš na reálný kus HW, **ověř
revizi na desce** (potisk u FPGA / u konektorů) proti tabulce v
[q3k/chubby75](https://github.com/q3k/chubby75/tree/master/5a-75b),
který je zdroj těchto údajů.

## Piny použité v tomto testovacím designu

| Signál | Pin | Popis |
|---|---|---|
| `clk_i` | **P6** | 25 MHz oscilátor, generovaný jedním z ethernet PHY čipů a rozvedený na FPGA. Pevný, nelze změnit. |
| `btn_n_i` | **R7** | Tlačítko `KEY+`, aktivní v log. 0. |
| `led_n_o` | **T6** | Onboard `DATA_LED`, aktivní v log. 0, zapojena jako open-drain. |

Viz [constraints/colorlight_5a75b_v8.lpf](../constraints/colorlight_5a75b_v8.lpf).

## Další rozhraní na desce (nepoužito v tomto testu, pro referenci)

- SPI flash (Winbond 25Q32JVSIQ): CS# = N8, SO = T7, SI = T8, SCK = N9
- SDRAM: ESMT M12L64322A (2M × 32bit)
- 2× Ethernet PHY: Realtek RTL8211FD
- 8× HUB75 výstupní konektor (J1–J8) přes 74HC245T level shiftery

## JTAG header (v8.0, potvrzeno)

4-pinová lišta hned vedle FPGA (U33), plus samostatná 2-pinová lišta pro
VCC/GND. Zdroj: [chubby75 hardware_V8.0.md](https://github.com/q3k/chubby75/blob/master/5a-75b/hardware_V8.0.md)
(staženo a ověřeno 2× nezávisle 2026-09-10).

| Header pin | Signál |
|---|---|
| J27 | TCK |
| J31 | TMS |
| J32 | TDI |
| J30 | TDO |
| J33 | 3.3V |
| J34 | GND |

Interní propojení na konkrétní ballnames FPGA (LFE5U-25F-6BG256C) není ve
zdrojové dokumentaci uvedeno — pro zapojení programátoru to není potřeba,
stačí header.

### Zapojení STM32F103 (DirtyJTAG firmware) na tento header

Pinout DirtyJTAG na Blue Pill (zdroj: [DirtyJTAG docs/install-bluepill.md](https://github.com/jeanthom/DirtyJTAG/blob/master/docs/install-bluepill.md)):

| STM32 pin | Signál | → Colorlight header pin |
|---|---|---|
| PA7 | TDI | J32 |
| PA6 | TDO | J30 |
| PA5 | TCK | J27 |
| PA3 | TMS | J31 |
| — | GND | J34 (**povinné**, společná zem) |

Celkem **5 drátů** (ne 6) — TRST (PA4) a SRST (PA2) na DirtyJTAG nejsou
pro běžné SRAM programování ECP5 přes JTAG potřeba, lze nechat
nezapojené.

⚠️ **Nezapojovat J33 (3.3V) na STM32**, pokud je Colorlight karta
napájena vlastním USB odděleně — dva aktivní 3.3V zdroje propojené
dohromady by se mohly přebíjet. Napájení řeší karta sama, J33 zůstává
nevyužité.

## Zdroje

- https://github.com/q3k/chubby75/blob/master/5a-75b/hardware_V8.0.md
  (primární zdroj pinoutu pro v8.0)
- https://www.weigu.lu/other_projects/fpga/fpga_ecp5_5a75b/index.html
- https://github.com/kholia/Colorlight-5A-75B
