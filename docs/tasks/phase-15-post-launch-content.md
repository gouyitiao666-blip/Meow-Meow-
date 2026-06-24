# Phase 15 — Post-Launch Content

Goal: Keep the world fresh after release — scheduled events, drop-in content
packs, optional community data, and ongoing balance. Mostly data-driven so it
ships without engine changes.

## 15.1 Event Calendar

| Task | Owner | Status |
|---|---|---:|
| `events.json` (date → event, rewards) | ⚙️ | ☐ |
| `EventCalendar` tied to TimeManager day/season | ⚙️ | ☐ |
| Event banner + reward UI (reuse FestivalUI) | 🎨 | ☐ |

## 15.2 Content Packs

| Task | Owner | Status |
|---|---|---:|
| New crops/fish/pets purely via JSON | ⚙️ | ☐ |
| Pack manifest + validation | ⚙️ | ☐ |
| New map area unlocks gated by progress | 🎨+⚙️ | ☐ |

## 15.3 Community / Mod Data

| Task | Owner | Status |
|---|---|---:|
| Load extra JSON from `user://mods/` | ⚙️ | ☐ |
| Safe-merge with base data (no crashes on bad data) | ⚙️ | ☐ |
| In-game pack list / toggle | 🎨 | ☐ |

## 15.4 Balance & Tuning

| Task | Owner | Status |
|---|---|---:|
| Central tuning constants (prices, grow times, XP) | ⚙️ | ☐ |
| Economy pass (sinks vs sources) | ⚙️ | ☐ |
| Telemetry hooks (local stats only) | ⚙️ | ☐ |

## 15.5 Optional Online (far future)

| Task | Owner | Status |
|---|---|---:|
| Cloud save (only if needed; backend required) | ⚙️ | ☐ deferred — out of MVP scope |
| Friend visits / sharing | 🎨+⚙️ | ☐ deferred |
