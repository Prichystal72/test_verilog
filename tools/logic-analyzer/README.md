# Logic Analyzer — webová aplikace (prototyp)

Samostatná, na ničem nezávislá webová aplikace (`index.html`, žádný
build krok, žádný server) — logický analyzátor ve stylu moderních
nástrojů (Saleae Logic 2 / PulseView): barevné průběhy, zoom/pan
myší, kolečkem, klávesnicí i dotykem (prioritně), dva měřicí kurzory,
dekódování sběrnic (SPI/I2C/UART) a export/import záznamu jako JSON.

## Spuštění

Stačí otevřít `index.html` v prohlížeči (dvojklik, nebo `file://`
cesta) — nic dalšího není potřeba.

## Stav — DEMO, ne hotový produkt

- **Data jsou generovaná softwarově** (16 kanálů: hodiny, 4bitový
  čítač, 2× PWM, SPI, I2C, UART, 2× náhodný šum) — tlačítko
  "Trigger & Capture" simuluje reálný postup (čekání na trigger →
  naplnění paměti → odeslání přes Wi-Fi) čistě časováním v
  JavaScriptu, **žádný hardware za tím není**.
- **Napojení na tuhle desku (Colorlight 5A-75B) ani na ESP32
  neexistuje** — to je koncept popsaný uživatelem (deska + ESP32 s
  webserverem jako backend), ale firmware/přenosová vrstva nejsou
  součástí tohoto commitu. Tahle aplikace je jen klientská část
  (frontend), připravená na napojení na skutečný zdroj dat (např.
  WebSocket/HTTP z ESP32) místo `generateTestData()`.
- Dekodéry (SPI/I2C/UART) jsou zjednodušené, navržené tak, aby
  správně dekódovaly vlastní testovací generátor — nejsou to plně
  spec-kompatibilní parsery pro reálná zařízení.

## Ovládání

- **Myš:** kolečko = zoom (na pozici kurzoru), tažení = posun,
  dvojklik = umístit kurzor A (shift+dvojklik = kurzor B).
- **Dotyk:** jeden prst = posun / tažení kurzoru, dva prsty (pinch) =
  zoom, dvojité poklepání = zoom na celý záznam.
- **Klávesnice:** šipky = posun, `+`/`-` = zoom, `Home`/`0` = fit.
- **Postranní panel:** zapnutí/vypnutí kanálu, přejmenování,
  seskupení podle sběrnice (COUNTER/SPI/I2C/UART).
- **Dekódy:** tlačítko "Dekódy" otevře panel s chronologickým
  seznamem dekódovaných rámců/bajtů.

## Ověřeno

Automatizovaně přes Playwright (headless Chromium) — načtení bez
console chyb, vykreslení všech 16 kanálů, zoom/pan, celý
trigger→capture flow, a správnost SPI dekodéru proti vlastnímu
generátoru dat (`MOSI` inkrementuje 0x00,0x01,…, `MISO = MOSI XOR
0xA5` — sedí).
