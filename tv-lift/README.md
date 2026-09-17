# TV-Lift

Wemos D1 mini (ESP8266) controlling a Xantron PREMIUM-600HE TV lift (OEM control unit LUMI LP66-46M-1B) over the RJ45 UART port of its control unit. No relays, nothing touches the 29 V motor side.

- `../tv-lift.yaml`: device config
- `lp66.h`: frame encoding, escaping, checksum and receive decoder
- `lp66_test.cpp`: host-side tests for `lp66.h`, including the reference frames from the protocol document

```sh
c++ -std=c++17 -Wall -o /tmp/lp66_test tv-lift/lp66_test.cpp && /tmp/lp66_test
```

## Wiring

Source: OEM document "Connection Interface and Communication Protocol of LP66 Series". UART is 3.3 V TTL, 115200 baud, 8N1, no flow control.

| RJ45 pin | T568B color  | Control unit | D1 mini                                     |
| -------: | ------------ | ------------ | ------------------------------------------- |
|        1 | white/orange | +5 V         | **do not connect**, current rating unknown  |
|        2 | orange       | GND          | G                                           |
|        3 | white/green  | RX           | D4 (GPIO2, TX), optional 470 Ω in series    |
|        4 | blue         | TX           | D7 (GPIO13, RX), optional 1 kΩ in series    |
|      5-8 | -            | not used     | leave open                                  |

```text
LP66 control unit                          Wemos D1 mini (USB powered)

RJ45 pin 2  GND  ------------------------- G
RJ45 pin 3  RX   <---[470R optional]------ D4 (GPIO2, TX)
RJ45 pin 4  TX   ----[1k optional]-------> D7 (GPIO13, RX)
RJ45 pin 1  +5V  -----------X              not connected (also not to 5V)
RJ45 pin 5-8     -----------X              not connected
```

TX and RX are crossed. The OEM drawing shows the socket looking into the control unit with the latch on top, pins `8 7 6 5 4 3 2 1` from left to right. Cable colors assume a T568B patch cable, **verify every wire with a continuity tester**.

The ESP8266 has only one full hardware UART, and USB serial uses it. TX runs on UART1 (GPIO2, transmit only), RX on UART0 with swapped pins (GPIO13). Both are hardware UARTs, no software serial. Side effects:

- Serial logging over USB is off (`logger: baud_rate: 0`). Read logs over Wi-Fi with the ESPHome dashboard or `esphome logs`. Flashing over USB still works.
- The onboard LED sits on GPIO2 and flickers when a frame is sent.
- GPIO2 must be high at boot. The UART line idles high, so this only fails if the control unit pulls its RX line low. If the D1 mini does not boot while connected, check the idle voltage of RJ45 pin 3.
- D8 (GPIO15) would be the usual swapped TX pin, but it must be low at boot, which conflicts with an idle-high UART line.

A simplified Xantron pinout PDF lists pins 6 and 7 as up/down contact inputs. That interface has no memory positions and is not used here. Keep pins 6 and 7 disconnected.

## Home Assistant entities

| Entity                                     | Frame                        | Notes                                     |
| ------------------------------------------ | ---------------------------- | ----------------------------------------- |
| Position 1 / Position 2                    | `06 01` / `07 01`            |                                           |
| Position 3                                 | `08 01`                      | disabled by default, firmware dependent   |
| Hoch starten / Runter starten              | `03 01` / `04 01`            |                                           |
| Stopp                                      | `03 00`, then `04 00`        | clears queued commands first              |
| Aktuelle Höhe als Position 1/2/3 speichern | `20 01` / `21 01` / `22 01`  | only while "Speichern freigeben" is on    |
| Speichern freigeben                        | -                            | turns off after one save or after 60 s    |
| Framezähler-Modus                          | -                            | counter byte order, see debugging         |
| Framezähler zurücksetzen                   | -                            |                                           |
| Letztes empfangenes Telegramm              | -                            | hex, only updated when it changes         |
| Letzter Systemfehler                       | -                            | last frame with message ID `A0`, hex      |
| Framezähler, gültige/ungültige Telegramme  | -                            | updated every 10 s                        |

Nothing is sent on boot or when Home Assistant reconnects. All buttons are one-shot.

## Protocol implementation

Control frame, host to control unit:

```text
FA | 17 | CMD | VALUE | COUNT_H | COUNT_L | CHECKSUM | FD
```

**Checksum:** XOR over the unescaped payload, from the message ID up to and including the counter. Start byte, end byte and escape bytes are not included. Example: `17 ^ 06 ^ 01 ^ 00 ^ 00 = 10`.

**Escaping:** after the checksum is appended, every `FA`, `FD` or `FE` in the payload (checksum included) gets an `FE` in front. Start and end byte are never escaped. Example with counter `00FA`: `FA 17 06 01 00 FE FA EA FD`.

**Frame counter:** 16 bit, starts at `0000` after every boot and increases by one per sent frame. It is kept in RAM only, so sending does not write to flash. The byte order is chosen at runtime with the "Framezähler-Modus" select (`lp66::append_counter`).

**Sending:** all frames go through the `send_lp66` script. It runs in `queued` mode with a 40 ms pause after each frame, so frames never overlap.

**Receiving:** `lp66::Decoder` collects bytes from `FA` to `FD`, removes escaping and checks the XOR checksum. Bytes outside a frame are ignored, a frame cut off by a new `FA` is dropped, frames over 64 bytes count as invalid. Valid and invalid frames are logged in hex, invalid ones as warnings, so a different checksum scheme on the control unit side shows up in the log.

## Assumptions and open questions

These points are not settled by the documentation:

- **Counter byte order:** not specified. Default is high byte first.
- **Manual movement:** it is assumed that `03 01` / `04 01` keep the lift moving until the matching stop frame (or the end stop). If the lift only moves while frames keep arriving, the manual buttons need to repeat the start frame.
- **Stop:** no universal stop is documented, so both stop frames are sent.
- **Position 3:** the protocol defines three memory positions, the Xantron manual only two.
- **Responses:** it is not known whether the control unit answers every frame.
- **System data (`03`):** contains an index and a 16 bit height value, but the layout, byte order, unit and scale are unknown. The config only logs these frames in hex, no height sensor yet.
- **Checksum on received frames:** assumed to work like sent frames.
- **Reset (`02`):** defined in `lp66.h` but has no button. It probably triggers a calibration run.

## Commissioning

Test without the TV mounted and with a clear travel path. The control unit's collision protection and end stops stay in charge.

1. Disconnect the lift from mains power.
2. Identify RJ45 pins and wire colors with a continuity tester.
3. Power the lift, measure between pin 1 and pin 2. Only continue if there are about 5 V and pin 2 is plausibly GND.
4. Power the lift off again. Flash the D1 mini and power it over USB only.
5. Connect only GND (pin 2) and D4 to CU RX (pin 3). Check that the D1 mini still boots and connects to Wi-Fi.
6. Power the lift. Press "Position 1" once, right after boot, so the counter is `0000`. The log shows `TX FA 17 06 01 00 00 10 FD (counter 0)`.
7. Check that the lift moves to the stored position 1. Press "Stopp" during the movement and check that it stops.
8. Connect CU TX (pin 4) to D7. Watch "Letztes empfangenes Telegramm" and the log for received frames.
9. Send at least ten commands in a row (positions, stop, up, down) and check the counter in the log.
10. Only then try "Speichern freigeben" and a save button.
11. Lower the logger level to `INFO` once everything works.

## Debugging

- **Nothing happens at all:** check TX/RX crossing, GND, and the pin numbering direction. The D4 LED should flicker on every command. Try "Framezähler zurücksetzen" and "Position 1" to rule out the counter.
- **Only the first command works:** change "Framezähler-Modus" and retry, in this order: "High-Byte zuerst" (default), "Low-Byte zuerst", "Immer 0000". Press "Framezähler zurücksetzen" between attempts and compare received frames in the log.
- **Only invalid frames received:** the control unit probably uses a different frame layout or checksum for its messages. Take the hex frames from the log to adjust `lp66::Decoder`.
- **Lift stops after a short move:** manual movement probably needs repeated start frames, see open questions.
- Received system data frames are the best source for the height value layout: move the lift and compare which bytes change.

## Sources

- Xantron RJ45 pinout PREMIUM-600HE: https://www.xantron.ch/mediafiles/PDF/wandhalterungen/PREMIUM-600HE-Pinbelegung-RJ45.pdf
- Xantron manual PREMIUM-600HE/LP66-46M: https://www.xantron.ch/mediafiles/PDF/wandhalterungen/PREMIUM-600HE-manual-multi.pdf
- Arduino forum on the LP66 UART port: https://forum.arduino.cc/t/uart-communication-between-arduino-uno-and-other-controller/702661
- OEM protocol document: https://forum.arduino.cc/uploads/short-url/1SzSmvdjiuLaih1iWS0IsTECClu.pdf
