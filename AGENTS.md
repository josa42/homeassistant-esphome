# Agent notes

ESPHome device configs for Home Assistant. The configs live in `/config/esphome` on Home Assistant and are mirrored into this repo with `sync.sh`.

## Layout

- `<device>.yaml`: one config per active device, at the top level
- `<device>/`: C/C++ sources a device includes (`esphome.includes`), e.g. `tv-lift/lp66.h`
- `enclosures/<device>.scad`: OpenSCAD enclosure for a device, with the exported `<device>.stl` next to it, repo-only
- `archive/`: retired devices, kept for reference only
- `docs/todos/<name>.md`: follow-up work that needs more information later, written in English
- `secrets.yaml.example`: template for `secrets.yaml`, which is gitignored and never committed

## Syncing with Home Assistant

Mount the Samba share first (`smb://homeassistant.local/config`), then:

- `./sync.sh`: pull from Home Assistant. Files deleted there are deleted here too.
- `./sync.sh --push`: push to Home Assistant, never deletes anything there.
- `--dry-run` shows what would change.

Only device files are synced: `*.yaml` and `.h`/`.c`/`.cpp` sources. Docs, enclosures, CI, dotfiles, `*_test.cpp` and `secrets.yaml` stay repo-only. A new repo-only directory needs an `--exclude` in `sync.sh`, otherwise a pull tries to delete it. Pushing and flashing are done by the user, don't do either without being asked.

## Validating

CI (`josa42/actions` shared ESPHome workflow) runs `yamllint` on the repo and `esphome config` on the top-level `*.yaml` files with dummy secrets. To check a config locally, copy it into a scratch directory next to a dummy `secrets.yaml` and run:

```sh
uvx esphome config <device>.yaml
```

Host-side tests for `tv-lift/lp66.h`:

```sh
c++ -std=c++17 -Wall -o /tmp/lp66_test tv-lift/lp66_test.cpp && /tmp/lp66_test
```

## Conventions

- Comments in the device configs are in German, match that when editing them.
- Commit messages follow Conventional Commits with the device as scope, e.g. `fix(dunstabzug): ...`.
- Live entity states, history and automations can be inspected through the Home Assistant MCP server. Check automations that act on a device's entities (e.g. "Küche - Linked Lights") before blaming the firmware.
