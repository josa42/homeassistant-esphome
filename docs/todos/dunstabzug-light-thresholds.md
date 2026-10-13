# Dunstabzug: calibrate light detection thresholds

## Background

While cooking, `led_status` (ADC on GPIO34) reports short phantom light toggles, mostly 0.6 to 1.5 s, some up to 12 s. Through the automation "Küche - Linked Lights" the kitchen light and the under-cabinet light toggle along. Seen on 2026-10-10 and 2026-10-11, always while or shortly after `sensor.kochfeld_betriebszustand` was `run`. Suspected cause: interference from the hob (induction) or the fan motor on the ADC line.

The old threshold was `> 1` V. As a stopgap, `led_status` now uses hysteresis with estimated values (on above 2.0 V, off below 1.0 V). The real level with the light on is unknown.

## Measure

The diagnostic sensors "Licht Spannung max" and "Licht Spannung min" report the maximum and minimum of the last 10 readings once per second.

- [ ] Level with light on, hob off
- [ ] Level with light off, hob off
- [ ] Level with light off, hob and fan on (interference peaks)
- [ ] Level with light on, hob and fan on

## Afterwards

- [ ] Set `threshold.upper` and `threshold.lower` in `dunstabzug.yaml` from the measurements
- [ ] If interference and on levels overlap: fix in hardware (shielded line, RC low-pass or capacitor on the pin)
- [ ] Optionally calibrate `multiply: 5.0` properly
- [ ] Remove the diagnostic sensors
- [ ] Check the logbook of `light.dunstabzug_licht` while cooking: no more toggles without a trigger
- [ ] Delete this file
