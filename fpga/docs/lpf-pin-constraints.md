# .lpf — schéma

## Anatomie jednoho pinu

```text
LOCATE COMP "led_n_o"   SITE "T6";
             |                |
        nazev z .v      fyzicky pin cipu (BGA)
                         --> dano DESKOU, nevymysli se

IOBUF PORT "led_n_o"   IO_TYPE=LVCMOS33   OPENDRAIN=ON;
            |                 |                 |
      stejny nazev    napet. banka pinu   elektricky rezim
                       --> dano DESKOU     --> dano ZAPOJENIM
```

## Rozhodovací strom

```text
signal v kodu (clk_i, led_n_o, ...)
        |
        v
  [kam na cipu fyzicky vede?] ---------> SITE "xx"     (schema desky)
        |
        v
  [jake napeti ma ta banka?]  ---------> IO_TYPE=LVCMOSxx   (schema desky)
        |
        v
  [jak je pin elektricky zapojeny?] ---> PULLMODE / OPENDRAIN / DRIVE
        |
        v
  [nextpnr-ecp5 pri buildu] -----------> OK, nebo chyba = spatny odhad
```

## Naše 3 piny konkrétně

```text
  CLK (P6)                 BTN (R7)                    LED (T6)
  --------                 --------                    --------

  25MHz            3V3 --[R pull-up]--+---- FPGA pin     FPGA pin --[R]-- LED --- 3V3
  oscilator  ----- FPGA pin           |                  (aktivni v 0 = "open drain")
  (natvrdo                       [tlacitko]
   na desce)                          |
                                      GND

  IO_TYPE=LVCMOS33         IO_TYPE=LVCMOS33            IO_TYPE=LVCMOS33
  (jen hodiny,             pull-up UZ JE na desce       OPENDRAIN=ON
   zadny dalsi rezim)      -> interni PULLMODE          (LED je aktivni-low,
                              netreba, ale nevadi         vodic jen "stahuje"
                              kdyby se pridal              k zemi/pousti)
```

## Atributy — rychlá tabulka

| Atribut     | Hodnoty            | Volí se podle...                            |
| ----------- | ------------------- | -------------------------------------------- |
| `IO_TYPE`   | LVCMOS33/25/18 ...  | napětí banky pinu (fixní, dané deskou)      |
| `PULLMODE`  | UP / DOWN / NONE    | jestli deska má/nemá externí pull rezistor  |
| `OPENDRAIN` | ON / OFF            | jestli je signál sdílený/aktivní-low HW     |
| `DRIVE`     | 4/8/12/16/24 mA     | zátěž na výstupu (LED bez tranzistoru...)   |
| `SLEWRATE`  | SLOW / FAST         | rychlé sběrnice (FAST) vs. běžný signál     |

`SITE` + `IO_TYPE` = dané deskou/schématem (nevymýšlí se).
`PULLMODE`/`OPENDRAIN`/`DRIVE`/`SLEWRATE` = dané tím, co je na pin fyzicky připojené.

Zdroj pinoutu desky: [board-colorlight-5a75b-v8.md](board-colorlight-5a75b-v8.md).
