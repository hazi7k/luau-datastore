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

## Tests

From the repo root:
Location: tests/test_datastore.luau

```bash
lune.exe run tests/test.luau
```

## API

## 📦 Datastore API (Quick Reference)

| Method | Description | Returns | Writes to Disk |
|------|-------------|---------|----------------|
| `CreateNewDatastore()` | Creates datastore and loads `storage.json` into memory | `Datastore` | ❌ |
| `GetData(UserId)` | Retrieves user data; applies validation, migrations, defaults | `table` | ⚠️ (Only if data changed) |
| `SetData(UserId, Data)` | Overwrites user data after full validation pipeline | `nil` | ❌ |
| `Update(UserId, Callback)` | Read–modify–write helper; callback must return table | `table` | ❌ |
| `Reset(UserId)` | Clears user data and reapplies schema + migrations | `table` | ❌ |
| `Delete(UserId)` | Removes user from datastore | `nil` | ❌ |
| `Save()` | Writes datastore to disk unconditionally | `nil` | ✅ |
| `FlushIfModified()` | Writes only if changes are pending | `boolean` | ✅ (conditional) |
| `_SetRaw(UserId, RawData)` | Injects raw data (no validation/migrations) | `nil` | ❌ |

### Notes
- All methods use **PascalCase**
- Disk writes are explicit via `Save()` / `FlushIfModified()`
- `GetData()` never writes unless it fixes or migrates data
- JSON writes are atomic (temp file → replace)


## Storage format

All users are stored in one JSON file:

- storage.json – current DB  (`storage.json`)
- backupfile.json – last corrupt JSON backup (if corruption detected)  (`backupfile.json`)

## Version history
#### v0.1.0
- Initial datastore with validation + migrations
#### v0.2.0
- Atomic JSON writes + reduced disk writes (FlushIfModified)
#### v0.3.0
- Added Reset, Delete, Save helpers

## Authors
### Hassan (@hazi7k)
### GitHub: https://github.com/hazi7k

