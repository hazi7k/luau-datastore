# lua-datastore (Luau + Lune)

A small datastore layer written in **Luau**, runnable locally using **Lune**.
Includes:

- JSON persistence (`storage.json`)
- Schema defaults
- Validation / normalization (type-fixing + clamping)
- Versioned migrations (v1 → v2)
- Safe writes (temp file → move)
- Minimal tests (no framework)

## Requirements

- Windows / macOS / Linux
- [Lune](https://lune-org.github.io/) installed (used to run Luau locally)

## Run

From the repo root:

```bash
lune.exe run main.luau
```

## Storage format

All users are stored in one JSON file:

- storage.json – current DB  (`storage.json`)
- backupfile.json – last corrupt JSON backup (if corruption detected)  (`backupfile.json`)
