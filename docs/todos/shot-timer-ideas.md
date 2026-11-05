# Shot Timer: feature ideas

Ideas collected for the shot timer at the coffee machine (`shot-timer.yaml`,
Waveshare ESP32-S3-Touch-LCD-1.28). None of them is planned yet.

## Hardware not used so far

- QMI8658 gyroscope and temperature. The temperature is the chip's own, so it is
  at best a rough "machine is warm" hint.
- CST816S gestures: swipe, long press, double tap.
- Bluetooth (BLE) of the ESP32-S3, e.g. as a Bluetooth proxy for Home Assistant
  in the kitchen.
- Battery connector with charger, battery voltage on GPIO1.
- No speaker or microphone. A beeper would need an extra buzzer on a free GPIO.

## More data for Home Assistant

- Last shot duration as a sensor plus an event per shot, for history, average
  shot time and shots per day (`utility_meter` on the `Shots` counter).
- Pump vibration per shot. Unclear whether it says anything about channeling or
  scale, it would need logging for a while first.
- Maintenance reminders after N shots (backflush, descaling), on the display
  and as a Home Assistant notification, with a reset button.

## Together with the smart plug (`switch.kaffeemaschine`)

- Heat-up indicator: the machine draws about 950 W constantly while heating,
  then the heater cycles. Home Assistant can detect "ready" from that and the
  display shows heating progress or "Bereit".
- Auto off after N minutes without a shot, instead of the fixed 17:00
  automation.
- Long press on the display turns the machine off through Home Assistant.

## On the device

- Profiles (single and double) with different target times, switched by swipe
  and exposed as a select in Home Assistant.
- Idle screen with more information: clock, time since the machine was turned
  on, shots today.
- Bluetooth scale: Home Assistant has an Acaia integration. Through the
  Bluetooth proxy the display could show weight and brew ratio during a shot.
  Most effort, needs a supported scale.

## Suggested order

1. Heat-up indicator
2. Last shot duration and shot event
3. Gestures
