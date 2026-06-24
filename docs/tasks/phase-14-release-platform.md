# Phase 14 — Release & Platform

Goal: Get the game out the door — a real front door (title screen), persistent
options, multiple input devices, exports, and the bits players expect from a
finished build. Still local-only, no backend.

## 14.1 Title Screen & Flow

| Task | Owner | Status |
|---|---|---:|
| Title scene (New Game / Continue / Quit) | 🎨 | ☑ `TitleScreen` (main scene) |
| `Continue` loads the save; `New Game` resets it | 🎨+⚙️ | ☑ |
| Save slots (pick/delete) | 🎨+⚙️ | ☐ single slot for now |
| Scene flow: title ↔ world | 🎨 | ☑ title → world |

## 14.2 Settings Persistence

| Task | Owner | Status |
|---|---|---:|
| `SettingsManager` (volume, options) saved to `user://` | ⚙️ | ☑ `settings.cfg` |
| Settings applied on launch | 🎨+⚙️ | ☑ on autoload `_ready` |
| Pause-menu settings write through to it | 🎨 | ☑ |

## 14.3 Input & Accessibility

| Task | Owner | Status |
|---|---|---:|
| Gamepad mappings for all actions | 🎨 | ☑ `ControllerSetup` (D-pad + stick + buttons) |
| Rebindable keys UI | 🎨+⚙️ | ☐ |
| Text size / high-contrast option | 🎨 | ☐ |

## 14.4 Localization

| Task | Owner | Status |
|---|---|---:|
| Extract UI strings to a translation table | 🎨+⚙️ | ☐ |
| Language select in settings | 🎨 | ☐ |

## 14.5 Export & Polish

| Task | Owner | Status |
|---|---|---:|
| Export presets (desktop + web) | ⚙️ | ☐ |
| App icon / window title / version stamp | 🎨+⚙️ | ☐ |
| Credits / about screen | 🎨 | ☐ |
| Smoke test the exported build | ⚙️ | ☐ |
