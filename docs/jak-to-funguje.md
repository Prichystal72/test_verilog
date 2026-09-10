# Jak to celé funguje — vysvětlení pro orientaci

Shrnutí celého řetězu, od Verilog kódu až po blikající LED na desce, a
co se dá dělat dál. Psáno jako referenční dokument, ne návod krok za
krokem (ten je ve [workflow.md](workflow.md)).

## 1. Od kódu k bitstreamu (softwarová část)

FPGA (Field-Programmable Gate Array) není procesor, který vykonává
instrukce — je to čip plný tisíců malých, přeprogramovatelných
logických bloků (LUT — lookup tables) a propojovací matice mezi nimi.
"Programování" FPGA neznamená nahrání programu, ale **nahrání
konfigurace, která fyzicky určí, jak jsou tyto bloky mezi sebou
propojené**. Výsledkem je vlastně digitální obvod, ne program.

Cesta od `rtl/blink.v` k `build/blink.bit`:

1. **Verilog (RTL)** — popisujete chování obvodu (`rtl/blink.v`:
   čítač, který dělí 25 MHz na ~2 Hz a přepíná LED). Je to textový
   popis, ne kód, co "běží" — spíš schéma zapsané textem.
2. **Synthesis (`yosys`)** — převede Verilog na síť logických bloků
   (LUT, klopné obvody/FF, sčítačky) dostupných v ECP5 čipu. Výstup:
   `build/blink.json`.
3. **Place & route (`nextpnr-ecp5`)** — rozhodne, **který konkrétní**
   LUT/FF na čipu se použije pro který kus logiky, a jak se propojí
   drátama uvnitř čipu (routing). Zohlední i `constraints/*.lpf`
   (které fyzické piny čipu = `clk_i`, `btn_n_i`, `led_n_o`). Spočítá
   i časování (Fmax) — u nás vychází přes 300 MHz, tedy velká rezerva
   nad potřebných 25 MHz.
4. **Bitstream packing (`ecppack`)** — zabalí výsledné umístění a
   propojení do binárního `.bit` souboru — to je přesná bitová mapa
   konfigurace pro daný čip (`LFE5U-25F-6CABGA256`).

Simulace (`sim.ps1`, `iverilog`+`vvp`) je oddělená větev — **nejede na
FPGA vůbec**, jen na PC vyhodnotí chování Verilog kódu podle
testbenche (`tb/blink_tb.v`) a řekne, jestli by se obvod choval
správně, kdyby se nahrál. Je to způsob, jak testovat logiku bez
hardwaru.

## 2. Jak se bitstream dostane do FPGA (JTAG)

JTAG je sériové rozhraní se 4 signály:

- **TCK** (Test Clock) — hodinový signál, řídí tempo přenosu.
- **TMS** (Test Mode Select) — řídí stavový automat uvnitř čipu
  (tzv. TAP — Test Access Port), který rozhoduje, co se zrovna děje
  (čtení ID čipu, nahrávání konfigurace, atd.).
- **TDI** (Test Data In) — data tekoucí **do** čipu.
- **TDO** (Test Data Out) — data tekoucí **z** čipu ven.

Je to posuvný registr: bity se posílají bit po bitu na `TDI`,
synchronně s `TCK`, a zároveň se bit po bitu čte to, co čip posílá
zpět na `TDO`. `TMS` mezi tím přepíná, jestli se zrovna posílá
instrukce (co má TAP dělat) nebo data (samotný obsah — třeba náš
bitstream).

Když jsme spustili `openFPGALoader --detect`, ve skutečnosti se poslal
speciální JTAG příkaz, který se zeptá čipu na jeho **IDCODE**
(výrobcem vypálené identifikační číslo) — proto přišlo zpátky
`0x41111043` / `lattice ECP5 LFE5U-25`. Tím jsme ověřili, že fyzická
cesta TCK/TMS/TDI/TDO/GND funguje.

Při `openFPGALoader ... build/blink.bit` se stejným způsobem, jen
mnohem déle, posílá celý obsah `.bit` souboru do konfigurační paměti
čipu. Nahráli jsme ho **do SRAM** (`-m`/`--write-sram`, výchozí
režim) — to je **dočasné**: po odpojení napájení konfigurace zmizí a
čip je zase "prázdný". Alternativa je nahrát do SPI flash
(`--write-flash`), odkud se FPGA nakonfiguruje sama při každém
zapnutí — to jsme zatím nedělali (a je rozumné to nedělat, dokud
nejste jistí designem — flash přepisujete natrvalo).

## 3. Kde je v tom STM32 (Blue Pill s DirtyJTAG)

Colorlight deska ani PC nemají přímo JTAG port navzájem kompatibilní
(PC nemá žádné GPIO piny). STM32 tady slouží jako **překladač/most**:

```
PC (USB) <--USB protokol--> STM32 (DirtyJTAG firmware) <--JTAG signály--> FPGA na Colorlightu
```

`openFPGALoader` na PC mluví s STM32 přes USB vlastním
protokolem (DirtyJTAG), a firmware na STM32 tyto USB příkazy překládá
na skutečné bit-banging přepínání pinů PA7/PA6/PA5/PA3 (TDI/TDO/TCK/
TMS) — fyzicky rozsvěcuje/zhasíná ty piny podle toho, co si USB
"objedná". STM32 tedy nic "nerozumí" Verilog ani bitstreamu — je to
čistě elektrický převodník mezi USB a JTAG.

## 4. Dá se to odposlouchávat? Ano, na dvou úrovních

**a) Fyzicky na JTAG vodičích (mezi STM32 a Colorlightem)** — logický
analyzátor (levný USB logický analyzátor, např. klon Saleae za pár
set Kč, funguje se `sigrok`/`PulseView`, které jsou dokonce součástí
podobných open-source sad jako tenhle toolchain) připojený paralelně
na TCK/TMS/TDI/TDO by ukázal přesně bit po bitu, co se posílá — dá se
tak vizuálně "dekódovat" JTAG protokol a vidět třeba i to IDCODE
čtení, co jsme dělali.

**b) Na USB mezi PC a STM32** — to, co si `openFPGALoader` a STM32
posílají přes USB (DirtyJTAG protokol, než se to přeloží na JTAG),
lze zachytit nástrojem jako Wireshark + USBPcap na Windows. Užitečné
spíš pro debugování/pochopení samotného DirtyJTAG protokolu než pro
sledování FPGA.

**c) `openFPGALoader -v` / `--verbose-level 2`** — nejjednodušší
varianta, softwarová: nástroj sám vypíše detailně, jaké JTAG příkazy
posílá a co dostává zpátky (to jsme použili u `--detect -v`).

**d) "Odposlech uvnitř FPGA"** — pokud byste chtěli sledovat, co se
děje **uvnitř** navrženého obvodu (ne na JTAG drátech, ale třeba
hodnoty vnitřních signálů/registrů za běhu), to už je jiná disciplína:
tzv. **on-chip logic analyzer** (u Xilinx se tomu říká ChipScope/ILA,
pro Lattice/otevřený toolchain existují obdoby, např. přes vestavěný
JTAG-UART/Wishbone debug most v projektech jako LiteX). To je nad
rámec současného jednoduchého blink designu, ale relevantní, až
budete dělat složitější logiku a chtít vidět, co se v ní reálně děje,
aniž byste museli vyvádět všechno na fyzické piny.

## 5. Co s tím teď — možné další kroky (bez závazku, jen na výběr)

- Upravit `rtl/blink.v` a vyzkoušet vlastní jednoduchou logiku
  (např. jiný dělič frekvence, čítač na 7-segmentovku, jednoduchý
  UART vysílač) — cyklus: uprav → `sim.ps1` → `build.ps1` →
  `openFPGALoader -c dirtyJtag build\blink.bit`.
- Nahrát bitstream do SPI flash (`--write-flash`), aby konfigurace
  přežila odpojení napájení — až budete jistí, že design je OK.
- Vyzkoušet logický analyzátor na JTAG vodičích, jen abyste na
  vlastní oči viděli, jak ten protokol vypadá.
- Nechat to tak, jak je — máte teď funkční a zdokumentovaný sandbox,
  ke kterému se dá kdykoliv vrátit.

Žádný z těchto kroků není nutný hned — tohle je spíš mapa možností, ne
plán.
