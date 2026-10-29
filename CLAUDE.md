# test_verilog – Colorlight 5A-75B (FPGA ECP5) + ESP32 logic analyzer

Komunikace česky, stručně. Tři nezávislé domény (viz README.md): `fpga/` (Verilog, sim/build, JTAG), `esp32/` (zatím jen architektura
interposer desky), `webapp/` (logic analyzer/generátor, zatím testovací data). Větev `logic-analyzer-webapp`.

## Stav hardwaru (v repu není vidět, stav k 21. 10. 2026)
- Původní karta má **jen výstupy** (8× HUB75 J1–J8 přes 74HC245). Vstupy J1–J4 v `esp32/` jsou nový návrh.
- 4 z 12 čipů 74HC245 jsou **přemostěné (A↔B) a zalité** – nejdou znovu testovat; nepředpokládat opak.
- Programátor JTAG = Blue Pill (STM32F103, DirtyJTAG), uživatel ho vrátil do dílny a nemusí dostat stejný kus. DirtyJTAG nemá build pro F411
  (Black Pill). Firmware `fpga/programmer/dirtyjtag.bluepill.v1.4.bin` (v2.0 mění piny → použít 1.4). Před nahráním ověřit, jaký čip programátor má.
- Test pinů: `fpga/pinmap_test/` (sim PASS, build OK, na desce nezkoušeno).

## Zásady
- Na desce nic nezkoušet bez domluvy. Dokumentace desky `fpga/docs/board-colorlight-5a75b-v8.md`, postup `fpga/docs/workflow.md`.
