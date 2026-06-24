# Current Status — Meow Meow ~

> Snapshot of what actually exists in the repo (not the vision). Date: 2026-06-23.
> Engine: **Godot 4.7** (`config/features=("4.7", "Forward Plus")`).
> Main scene: `res://scenes/world/World.tscn`.

## TL;DR
**MVP (Phases 1–5) is complete and verified.** Headless smoke tests pass
(`build/TestWorld.tscn` and `build/test_backend.gd`). Remaining work is Phase 6
("Cozy Expansion"), which is mostly **blocked on missing art** (pets beyond cat,
NPCs) or needs design decisions (decoration placement, shop, tools).

## Files / scenes / scripts that exist

### Scenes (`scenes/`) — frontend (Claude's area)
- `player/Player.tscn` + `Player.gd` — `CharacterBody2D`, 4-dir movement, walk
  animation from sprite sheets, `Camera2D` child.
- `pets/CatPet.tscn` + `CatPet.gd` — non-physics follower with eased movement.
- `world/World.tscn` + `World.gd` — builds the whole 52×46 map from code
  (ground, river+bridge, paths, farm, decorations, borders, water collision),
  spawns player/cat, sets camera limits, and wires save/load (F5/F9 + on quit).
- `world/MeowTileSet.tres` — TileSet (grass, dirt path, water + 8 directional
  water edge/corner tiles, soil, wet soil, bridge).
- `farming/FarmTile.tscn` + `FarmTile.gd`, `farming/Crop.tscn` + `Crop.gd`,
  `farming/CropData.gd` (reads `data/crops.json`; `class_name CropData`).
- `fishing/FishingSpot.tscn` + `FishingSpot.gd` (`Area2D`, `class_name FishingSpot`).
- `ui/InventoryUI.tscn` + `InventoryUI.gd` (`CanvasLayer`, toggled with `I`/`Esc`).
- `SpriteSheet.gd` — shared sprite-sheet frame extraction helper.

### Scripts (`scripts/`) — backend (Codex's area), all autoload singletons
- `inventory/Inventory.gd` — `add_item/remove_item/get_count/has_item/clear/
  to_dict/from_dict/get_all_items` + `inventory_changed` signal.
- `data/ItemDatabase.gd` — loads `data/items.json`.
- `data/FishDatabase.gd` — loads `data/fish.json`, `get_wait_time_seconds`,
  `roll_reward`.
- `data/PetDatabase.gd` — loads `data/pets.json`.
- `data/DecorationDatabase.gd` — loads `data/decorations.json`.
- `save/SaveManager.gd` — local JSON save/load at `user://save_v1.json`,
  versioned (`SAVE_VERSION = 1`), with save/load signals.

### Autoloads (from `project.godot`)
`Inventory`, `ItemDatabase`, `FishDatabase`, `PetDatabase`, `DecorationDatabase`,
`SaveManager`. (Note: `CropData` is a `class_name`, **not** an autoload.)

### Data (`data/`)
`items.json`, `crops.json`, `fish.json`, `pets.json`, `decorations.json`.

### Tests (`build/`)
- `build/test_world.gd` + `build/TestWorld.tscn` — world/collision/fishing/save smoke test.
- `build/test_backend.gd` — backend smoke test (inventory, item/fish/pet/decoration DBs, save).
- Run: `godot --headless --path . res://build/TestWorld.tscn`
  and `godot --headless --path . -s build/test_backend.gd`.

## Systems that appear implemented
- **Player movement + camera follow** — done.
- **Pet follower (cat)** — done (idle/walk, non-blocking).
- **World map + collision** — done (40×40-style large map; border walls +
  per-tile water collision with the bridge excluded).
- **Farming loop** — done (plant carrot → grow → harvest into inventory).
- **Fishing loop** — done (interact → wait → reward roll → fish into inventory).
- **Inventory + UI** — done (global store + UI panel reading it).
- **Save / load** — done (player position + inventory; F5 save, F9 load,
  save-on-quit, load-on-start).

## Systems incomplete / not started
- **Decoration placement system** — decorations are placed by `World.gd`; there
  is no *player-driven* placement/build mode. Backend `decorations.json` +
  `DecorationDatabase` exist.
- **More pets (dog/duck/bunny)** — defined in `pets.json` + `PetDatabase`, but
  **no art** and no pet scenes beyond the cat.
- **NPCs + dialogue UI** — not started; no NPC art, no dialogue data.
- **Shop + money** — not started (a `coin` item and `coin` assets exist).
- **Tool upgrades** — not started (tool icons exist; no tool system).
- **Audio/music** — not present (no `assets/audio/` folder).

## Compile errors / known issues
- No known compile errors. Project boots clean headless (exit 0) and both smoke
  test suites pass as of this snapshot.
- Historical note (resolved): directional water-edge tiles shipped at 32×32 and
  were upscaled to 64×64 to match the tile grid. If the asset generator re-emits
  them at 32×32, the river tiles can break again — keep tiles at 64×64.
- `SaveManager` writes to `user://save_v1.json`; an existing save will be loaded
  on start (can mask "new game" behavior in manual testing — delete it to reset).

## Assets that already exist (high level)
Rich set present under `assets/`: player (walk 4-dir, directional idles, action
poses), pets/creatures (cat/dog/duck/bunny/eagle/penguin/bird/hamster/crab),
a large tile set including interior and endgame tiles, nature props, farming
crop stages/icons including corn and golden variants, fishing/legendary fish,
items/dishes, UI (panels/prompts/icons/settings/shop/save/mastery), large
stereoscopic 3/4 building props, upgraded in-world tool sprites, effects, shadows, vehicles, and
animated PNGs.
See [assets-needed.md](assets-needed.md) for the per-category checklist.

## Assets that are missing
- No major PNG asset blockers currently listed in `docs/assets-needed.md`.
- SFX remain out of scope for Phase 12; visual effects cover feedback.

## Next safest task
Continue integrating existing Phase 12/13 systems, or run a manual playtest pass
against the enlarged asset library. Shop, pets, NPCs, interiors, settings, and
endgame concepts are no longer blocked on missing PNG art.
