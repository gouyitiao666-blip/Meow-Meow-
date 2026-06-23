# System Breakdown — Meow Meow ~

> One entry per system: purpose, main files, current status, next step.
> Backend systems are autoload singletons under `scripts/`; frontend systems are
> scenes under `scenes/`. See [../CLAUDE.md](../CLAUDE.md) (frontend) and
> [../AGENTS.md](../AGENTS.md) (backend) for ownership.

## Player movement
- **Purpose:** 4-direction walk with animation; the thing the player controls.
- **Main files:** `scenes/player/Player.tscn`, `scenes/player/Player.gd`,
  `scenes/SpriteSheet.gd`, input actions in `project.godot`
  (`move_up/down/left/right`, `interact`, `inventory`).
- **Status:** Implemented (Phase 1).
- **Next step:** Optional polish — directional idle art, run, footstep SFX.

## Camera follow
- **Purpose:** Keep the player centered; clamp to map bounds.
- **Main files:** `Camera2D` child in `Player.tscn`; limits set in `World.gd`
  (`_ready` → `cam.limit_right/bottom = MAP_W/MAP_H * TILE`).
- **Status:** Implemented. (Limits are set from code because the `.tscn` limits
  were sized for the old small map.)
- **Next step:** None required; consider zoom or soft deadzone later.

## Pet follower
- **Purpose:** A cat that trails the player and never blocks them.
- **Main files:** `scenes/pets/CatPet.tscn`, `scenes/pets/CatPet.gd`,
  `scenes/SpriteSheet.gd`; data in `data/pets.json` + `scripts/data/PetDatabase.gd`.
- **Status:** Implemented for the cat (eased follow, idle/walk, non-physics).
- **Next step:** Generalize to data-driven pets (read `PetDatabase`) so dog/
  duck/bunny work once their art exists. **Blocked on pet art.**

## World map
- **Purpose:** The tile-based open world + collisions + prop placement.
- **Main files:** `scenes/world/World.tscn`, `scenes/world/World.gd`,
  `scenes/world/MeowTileSet.tres`.
- **Status:** Implemented. 52×46 map built from code: forest, river+bridge,
  pond, paths, farm, home, shop, workbench; border walls + per-tile water
  collision (bridge excluded); nature props placed with a reservation + spacing
  guard, all solid. NPCs + ambient pets have solid footprints too.
- **Next step:** If decoration placement lands, let player-placed objects share
  the same reservation/collision approach.

## Farming
- **Purpose:** Plant → grow → harvest loop.
- **Main files:** `scenes/farming/FarmTile.tscn`/`.gd`, `Crop.tscn`/`Crop.gd`,
  `CropData.gd`; data in `data/crops.json`; `Inventory` autoload for items.
- **Status:** Implemented for carrot (timed growth via `Crop.gd`, reads
  `crops.json`, harvest adds to `Inventory`).
- **Next step:** Add more crops to `crops.json` + art; optional watering/tools.

## Fishing
- **Purpose:** Interact near water → wait for bite → reward roll → catch.
- **Main files:** `scenes/fishing/FishingSpot.tscn`/`.gd`; data in
  `data/fish.json` + `scripts/data/FishDatabase.gd`; `Inventory` for the catch.
- **Status:** Implemented (river spot; `FishDatabase.get_wait_time_seconds` +
  `roll_reward`; reward added to inventory).
- **Next step:** More fish/rewards in `fish.json`; bite/catch feedback polish.

## Inventory
- **Purpose:** Global item store + on-screen display.
- **Main files:** `scripts/inventory/Inventory.gd` (autoload, source of truth),
  `scenes/ui/InventoryUI.tscn`/`.gd` (view only); item defs in `data/items.json`
  via `scripts/data/ItemDatabase.gd`.
- **Status:** Implemented. UI reads `Inventory.get_all_items()` and refreshes on
  the `inventory_changed` signal. Toggle with `I` (or `Esc` to close).
- **Next step:** Item stacking limits / categories / selected-slot interactions
  as gameplay grows.

## Save / load
- **Purpose:** Persist and restore progress locally (no backend).
- **Main files:** `scripts/save/SaveManager.gd` (autoload, `user://save_v1.json`,
  versioned); wiring in `World.gd` (`_load_game` on start, `_save_game` on quit,
  `F5` save / `F9` load).
- **Status:** Implemented. Saves player position + `Inventory.to_dict()`; loads
  and restores both. Save shape matches the README contract (also has `pets`,
  `money`, `unlocked_areas` defaults).
- **Next step:** Persist additional state as systems land (planted crops,
  placed decorations, money, unlocked areas, pets).

## Decoration placement
- **Purpose:** Let the player place/move decorations to customize their space.
- **Main files (data ready):** `data/decorations.json`,
  `scripts/data/DecorationDatabase.gd`. Build-preview/highlight art exists in
  `assets/ui/` (`build_preview_shadow`, `tile_highlight_green/red`,
  `selection_cursor`). No placement *scene/UI* yet.
- **Status:** Not implemented (decorations currently hard-placed by `World.gd`).
- **Next step:** Design a build mode: pick a decoration → preview on grid →
  confirm placement → reserve tile + add collision (mirror `World.gd`'s
  `_place_structure`/reservation logic). Needs a design decision on UX.

## NPC dialogue
- **Purpose:** Villagers the player can talk to; simple dialogue UI.
- **Main files:** none yet. Dialogue UI art exists in `assets/ui/`
  (`dialogue_box`, `dialogue_nameplate`, `dialogue_next_arrow`, `speech_bubble`).
- **Status:** Not started. **Blocked on NPC character art** and a dialogue data
  contract (e.g., `data/dialogue.json`).
- **Next step:** Agree a dialogue JSON shape with backend; build `NPC.tscn` +
  `DialogueUI.tscn` once NPC art exists.

## Shop
- **Purpose:** Buy seeds/decorations and sell crops/fish for coins.
- **Main files:** none yet. `coin` item + `coin_icon`/`coin_drop` art and shop
  *building* art exist; a money store does not (save has a `money` default only).
- **Status:** Not started.
- **Next step:** Add a money system (backend) + a shop UI (frontend) reading
  `ItemDatabase`/`DecorationDatabase` prices. Buildable with existing assets.

## Tools
- **Purpose:** Hoe/watering can/axe/fishing rod; usage and upgrades.
- **Main files:** none yet. Tool icons exist in `assets/tools/`; a tool hotbar
  exists in `assets/ui/`. Player has hoe/watering-can/rod *poses*.
- **Status:** Not started (farming/fishing currently work without an explicit
  tool/equip system).
- **Next step:** Define a tool/equip model (hotbar selection → action), then
  tool tiers/upgrades. Needs a design decision.
