# TASKS.md — Meow Meow ~ Task Board

Shared task board between **Claude (Manager + Frontend)** and **Codex
(Backend)**. See [CLAUDE.md](CLAUDE.md), [AGENTS.md](AGENTS.md),
[README.md](README.md).

**Owners:** 🎨 Frontend = Claude · ⚙️ Backend = Codex
**Status:** ☐ todo · ◐ in progress · ☑ done · 🔗 blocked (needs other side)

---

# Current Task: Expand World Map Using Existing Assets

**Owner:** 🎨 Frontend (Claude) · **Status:** ☑ done (2026-06-23)

**Where this fits:** This is a **Phase 1 ↔ Phase 6 bridge**. It completes the
remaining Phase 1 world work (`1.5` per-tile water collision) and lays the cozy
foundation that Phase 6 (Cozy Expansion) and Phase 4 (Fishing) build on. Run it
now, after `5.3`, before starting Phase 6 decoration *systems*.

**Goal:** Make the world bigger and more complete using only assets already in
the project. Map grew from **20×12 → 40×28** tiles, painted from code in
`scenes/world/World.gd`, with directional water tiles added to `MeowTileSet.tres`.

## Map Expansion Tasks
| # | Task | Status |
|---|------|--------|
| 1 | Bigger world map (40×28, cozy, walkable, cat follows) | ☑ |
| 2 | Home area (house, path, pet bed, fences, flowers, bushes) | ☑ |
| 3 | Farm area (soil plots, wet-soil strip, dirt path, fences) | ☑ |
| 4 | River + fishing (water, edges, bridge, marker, rocks, flowers) | ☑ |
| 5 | Forest area (big/small trees, bushes, mushrooms, rocks, log, path) | ☑ |
| 6 | Main dirt path connecting home/farm/river/forest | ☑ |
| 7 | Object placement from existing assets only | ☑ |
| 8 | Collision + Y-sort layering (house/trees/rocks/water/fence) | ☑ |
| 9 | Suggested layout (forest TL, river TR, farm BL, home BC, empty BR) | ☑ |
| 10 | Testing checklist | ☑ (see below) |

**Testing checklist (verified):**
- ☑ Water collision = 55 tiles, **bridge excluded** → player can't cross water
  except the bridge (`build/TestWorld.tscn` smoke test, all PASS).
- ☑ 12 farm plots present; fishing spot marker present (group `fishing_spot`).
- ☑ Player spawn (home, tile 20,23) is not stuck in a collider.
- ☑ Boots clean headless (exit 0); layout confirmed via a faithful top-down
  render that mirrors `World.gd`'s placement.
- Solid props (house, trees, rocks, fences, pet bed, crate, border trees) use
  the existing footprint-collision; cat is a non-physics follower (no blocking).

**Expected result — DONE:** a larger cozy world with a forest-clearing feel —
home + farm + river/fishing + forest connected by a dirt-path crossroads, framed
by a tree border, all from existing assets.

---

# Asset Pack Update — 2026-06-23

**Owner:** ⚙️ Codex asset pipeline · **Status:** ☑ done

Generated and normalized the pasted **142-file cozy Godot 4 asset pack** using
the `generate2dmap` tile/prop workflow: terrain remains tile-oriented for
Godot TileMap use, while props/buildings/effects/UI/animated sheets are separate
PNG assets. Raw image-generation sheets and prompts are kept under
`build/generated-assets/raw/`; deterministic slicing/export logic lives in
`build/export_full_asset_pack.py`.

**Outputs:**
- `build/full_asset_pack_manifest.json`
- `build/full_asset_pack_contact_sheet.png`
- Requested PNG filenames under `assets/characters/`, `assets/pets/`,
  `assets/tiles/`, `assets/nature/`, `assets/farming/`, `assets/tools/`,
  `assets/fishing/`, `assets/buildings/`, `assets/vehicles/`, `assets/ui/`,
  `assets/shadows/`, `assets/effects/`, and `assets/animated/`

**Verified:**
- ☑ Exact 142 requested filenames exist.
- ☑ PNG validation passed; no empty transparent outputs.
- ☑ Animated sheets have expected frame-sheet dimensions.
- ☑ `godot --headless --path . --script res://build/test_backend.gd`
- ☑ `godot --headless --path . res://build/TestWorld.tscn`
- ☑ `godot --headless --path . --quit-after 2`

---

# Phase 6 Asset Pack Update — 2026-06-23

**Owner:** ⚙️ Codex asset pipeline · **Status:** ☑ done

Generated the pasted **123-file Phase 6 asset pack** for pets, NPCs,
portraits, decoration placement, extra decorations, shop UI, additional crops,
fish icons, tools, collectibles, dialogue UI, and animated decoration support.
The pass used the `generate2dmap` tile/prop workflow for map-facing assets and
the `generate2dsprite` workflow for pets, NPCs, portraits, and player actions.

**Outputs:**
- `build/export_phase6_asset_pack.py`
- `build/phase6_asset_pack_manifest.json`
- `build/phase6_asset_pack_contact_sheet.png`
- Raw generated sheets and prompt sidecars under `build/generated-assets/raw/`
- Requested PNG filenames under `assets/pets/`, `assets/npc/`,
  `assets/buildings/`, `assets/farming/`, `assets/fishing/`, `assets/tools/`,
  `assets/characters/`, `assets/items/`, `assets/ui/`, `assets/effects/`, and
  `assets/animated/`

**Verified:**
- ☑ Exact 123 requested Phase 6 filenames exist.
- ☑ PNG validation passed; no empty transparent outputs.
- ☑ `godot --headless --path . --script res://build/test_backend.gd`
- ☑ `godot --headless --path . res://build/TestWorld.tscn`
- ☑ `godot --headless --path . --quit-after 2`

---

## Phase 1 — Basic World
| # | Task | Owner | Status |
|---|------|-------|--------|
| 1.1 | Create Godot 4 project + folder structure | 🎨 | ☑ |
| 1.2 | Player movement (4-direction) | 🎨 | ☑ |
| 1.3 | Camera follows player | 🎨 | ☑ |
| 1.4 | Small test map (TileMap) | 🎨 | ☑ |
| 1.5 | Collision on walls/water | 🎨 | ☑ (border walls + per-tile water collision, bridge excluded) |

## Phase 2 — Pet Follower
| # | Task | Owner | Status |
|---|------|-------|--------|
| 2.1 | CatPet.tscn + sprite | 🎨 | ☑ |
| 2.2 | Pet follows player (keeps distance) | 🎨 | ☑ |
| 2.3 | Idle + walk animation | 🎨 | ☑ (4-frame walk cycle via AnimatedSprite2D + SpriteSheet.gd) |
| 2.4 | Pet does not block player | 🎨 | ☑ (non-physics follower) |

## Phase 3 — Farming
| # | Task | Owner | Status |
|---|------|-------|--------|
| 3.1 | `Inventory.gd` API + `inventory_changed` signal | ⚙️ | ☑ |
| 3.2 | `ItemDatabase.gd` loads `items.json` | ⚙️ | ☑ |
| 3.3 | `crops.json` — carrot (grow time, stages, yield) | ⚙️ | ☑ |
| 3.4 | Crop growth logic (time-based) | 🎨 | ☑ (runs in `Crop.gd`, reads backend `crops.json`) |
| 3.5 | FarmTile.tscn + plant interaction | 🎨 | ☑ |
| 3.6 | Crop.tscn + visual growth stages | 🎨 | ☑ |
| 3.7 | Harvest → `Inventory.add_item("carrot", 1)` | 🎨 | ☑ |

## Phase 4 — Fishing
| # | Task | Owner | Status |
|---|------|-------|--------|
| 4.1 | `fish.json` — small fish + reward table | ⚙️ | ☑ |
| 4.2 | Fishing reward roll logic | ⚙️ | ☑ |
| 4.3 | FishingSpot.tscn near river | 🎨 | ☑ |
| 4.4 | Fishing interaction (press → wait → catch) | 🎨 | ☑ |
| 4.5 | Caught fish → `Inventory.add_item(...)` | 🎨 | ☑ |

## Phase 5 — Inventory + Save
| # | Task | Owner | Status |
|---|------|-------|--------|
| 5.1 | `SaveManager.gd` save/load local JSON | ⚙️ | ☑ |
| 5.2 | `Inventory.to_dict()` / `from_dict()` | ⚙️ | ☑ |
| 5.3 | InventoryUI.tscn (reads Inventory) | 🎨 | ☑ |
| 5.4 | Save player position + inventory | 🎨+⚙️ | ☑ |
| 5.5 | Load save on game start | 🎨+⚙️ | ☑ |

## Phase 6 — Cozy Expansion (post-MVP)
| # | Task | Owner | Status |
|---|------|-------|--------|
| 6.1 | Decorations (fence, bench, pet bed) | 🎨+⚙️ | ☑ build-mode placement system + save persistence |
| 6.2 | More pets (dog, duck, bunny) | 🎨+⚙️ | ☑ data-driven Pet; cat follows, dog/duck/bunny ambient in thematic areas |
| 6.3 | NPCs + dialogue UI | 🎨+⚙️ | ☑ 4 NPCs + DialogueUI (greeting+lines) reading DialogueDatabase |
| 6.4 | Shop + money system | 🎨+⚙️ | ☑ shop UI + buy/sell + in-world store trigger (Wallet/ShopDatabase) |
| 6.5 | More crops / fish / map areas | 🎨+⚙️ | ☑ per-plot crops (5 types) + pond fishing spot (pond fish table) |
| 6.6 | Tool upgrades | 🎨+⚙️ | ☑ workbench + ToolUpgradeUI (spend coins+materials via ToolDatabase) |

---

## Shared Contracts (agree before coding)
| Contract | Defined by | Used by | Status |
|----------|-----------|---------|--------|
| `Inventory` public API + signal | ⚙️ | 🎨 UI, farming, fishing | ☑ |
| Save file JSON shape | ⚙️ | 🎨 player, 🎨 UI | ☑ |
| `crops.json` field schema | ⚙️ | 🎨 Crop.tscn | ☑ |
| `fish.json` reward schema | ⚙️ | 🎨 FishingSpot | ☑ |

> When a 🔗 blocked task's dependency lands, flip it to ☐ and start.

## Frontend Notes (Claude) — updated 2026-06-23 (Phase 6.2/6.3/6.5/6.6 — all done)

**Phase 6 frontend is now complete (6.1–6.6).** New this pass:
- **6.2 Pets:** `scenes/pets/CatPet.gd` is now data-driven via `pet_id` (reads
  `PetDatabase` for walk sheets + speed/follow_distance) with a `follow` flag.
  The cat follows the player; `World._build_pets()` spawns dog (home), duck
  (river bank), bunny (farm) as ambient idle animals.
- **6.3 NPCs + dialogue:** `scenes/npc/NPC.{gd,tscn}` (`class_name NPC`, Area2D,
  interact to talk) + `scenes/ui/DialogueUI.{gd,tscn}` (portrait + name + greeting
  then lines, advance with Next/interact, reads `DialogueDatabase`).
  `World._build_npcs()` places farmer/fisher/shopkeeper/villager.
- **6.5 More crops / map area:** `FarmTile.crop_id` is now per-plot; the 12 plots
  cover all 5 crops (carrot/strawberry/tomato/pumpkin/catnip) and starter seeds
  grant one set of each. Added a **pond** (bottom-right) via a reusable
  `_paint_water_rect()` + a second `FishingSpot` with `spot_id = "pond"`
  (catfish/golden_fish/etc. from `fish.json`). `FishingSpot.spot_id` is now configurable.
- **6.6 Tool upgrades:** `scenes/ui/ToolUpgradeUI.{gd,tscn}` + a `WorkbenchTrigger`
  by a shed building. Spends coins (`Wallet`) + materials (`Inventory`) per
  `ToolDatabase.get_upgrade_cost`. Tool levels held at runtime.
- **6.1 follow-up completed:** decoration placement now **charges `cost` via
  `Wallet`** on place, **refunds** on remove, and persists placed decorations
  through the save file.
- **Persistence completed:** tool upgrade levels now persist through
  `tool_levels` in the save file.
- Verified headless: `build/TestWorld.tscn` extended (pets=4, distinct plot
  crops=5, fishing spots=2, NPCs=4, dialogue opens, hoe→Lv2 spends 75c/5 wood/
  2 stone) — all PASS; backend smoke tests pass; boots clean.
- **Persistence fields:** saves now include `decorations` and `tool_levels`.

## Frontend Notes (Claude) — updated 2026-06-23 (Phase 6.4 shop)

**6.4 Shop + money — DONE:**
- New `scenes/ui/ShopUI.tscn` + `ShopUI.gd` (a `CanvasLayer`, group `shop_ui`):
  dimmed centered panel showing the shop name, the player's coins, and a row per
  catalog item with **Buy**/**Sell** buttons + owned count. Pure view over the
  backend: calls `ShopDatabase.buy_item/sell_item(shop_id, item_id, 1, Inventory,
  Wallet)` and refreshes on `Wallet.money_changed` + `Inventory.inventory_changed`.
  Buy disabled when unaffordable; Sell disabled when none owned.
- New `scenes/shop/ShopTrigger.gd` (`class_name ShopTrigger`, an `Area2D`): an
  interact spot in front of a shop building; press **interact** when near to open
  the shop. Builds its own collision + talk prompt (mirrors FishingSpot pattern).
- `World.gd`: `_build_shop()` instances the ShopUI, places a `shop_building`
  (general store) east of the central crossroads, and drops a `GeneralStoreTrigger`
  (`shop_id = "general_store"`) in front of it.
- Money persists automatically — `SaveManager` already reads/writes `Wallet`.
- Verified headless (`build/TestWorld.tscn`): buy carrot_seed (money 100→95,
  +1 seed), sell it back (money 95→96, 0 seed), shop UI + trigger present — all PASS.
- **Note:** decoration build mode (6.1) is still free; now that `Wallet` exists,
  charging decoration `cost` on place is a small follow-up.

## Frontend Notes (Claude) — updated 2026-06-23 (Phase 6.1 build mode)

**6.1 Decoration placement (build mode) — DONE (placement core):**
- New `scenes/world/DecorationPlacer.gd` (added to the World tree from
  `World._ready`). Press **B** to toggle build mode; **mouse wheel** cycles the
  decoration; **left click** places it; **right click** removes a placed one;
  **B** exits. Shows a translucent ghost preview + a green/red footprint
  highlight (`assets/ui/tile_highlight_green/red.png`) for valid/invalid tiles.
- Reads `DecorationDatabase` (id, asset, solid, footprint). Placement/validation
  lives in `World` public API: `tile_from_world`, `is_buildable_tile`,
  `can_place_footprint`, `place_decoration(id, origin)`, `remove_decoration_at`.
  Placement reuses the prop footprint-collision (`_spawn_prop_at_base`, now
  returns the node) and the existing `_reserved` set, so decorations can't land
  on paths/water/props/spawn and stay collidable.
- Placement charges `cost` through `Wallet`, refunds on remove, and persists
  player-placed decorations through the save file's `decorations` array.
- Verified headless in `build/TestWorld.tscn`: place → tile becomes occupied →
  remove → tile free again → save/load restores the placed decoration (all PASS),
  plus the full prior suite still green.

## Backend Notes

- Codex completed `3.1`, `3.2`, `3.3`, and `5.2`: added `Inventory` and
  `ItemDatabase` autoloads, item definitions in `data/items.json`, and the
  carrot crop contract in `data/crops.json`.
- Codex completed `4.1` and `4.2`: added `FishDatabase` autoload,
  `data/fish.json`, one `river` fishing spot, and reward roll helpers for the
  frontend fishing interaction.
- Codex completed `5.1`: added `SaveManager` autoload with local JSON save/load
  at `user://save_v1.json`. The save file keeps the MVP shape from README and
  versions through `SAVE_VERSION` plus the path name for future migrations.
- Frontend can now call `Inventory.add_item(id, amount)`,
  `Inventory.remove_item(id, amount)`, `Inventory.get_count(id)`,
  `Inventory.to_dict()`, and `Inventory.from_dict(data)`.
- Frontend can call `SaveManager.save_game()` to save the current player group
  position plus `Inventory.to_dict()`, and `SaveManager.load_game()` to read the
  file and restore inventory. The returned dictionary contains
  `player_position`, `inventory`, `pets`, `money`, and `unlocked_areas`.
- Phase 4 fishing is wired through `scenes/fishing/FishingSpot.tscn`: stand near
  the river bobber, press interact, wait for the backend bite timer, then the
  rolled reward is added through the existing `Inventory` autoload.
- Phase 5 save/load is wired in `World.gd`: existing saves load on game start,
  new games get starter carrot seeds, F5 saves, F9 loads, and window close saves
  player position plus inventory through the existing `SaveManager`.
- Phase 6.2 backend pet data is ready in `data/pets.json` and `PetDatabase`:
  cat/dog/duck/bunny have stable IDs, gameplay metadata, favorite items, and
  generated idle/walk/sleep/emote asset paths.
- Phase 6.1 backend decoration data is ready in `data/decorations.json` and
  `DecorationDatabase`: fence, pet bed, crate, garden, light, well, fountain,
  and village props have stable IDs, costs, categories, solidity, footprints,
  and asset paths for placement/build mode.
- Phase 6.3 backend dialogue data is ready in `data/dialogue.json` and
  `DialogueDatabase`: farmer, fisher, shopkeeper, and villager have names,
  roles, sprites, portraits, greetings, and line arrays.
- Phase 6.4 backend shop/money data is ready in `data/shop.json`,
  `ShopDatabase`, and `Wallet`: shop catalogs expose buy/sell prices and helper
  methods can buy/sell through `Inventory` plus wallet money.
- Phase 6.5 backend crop/fish data is ready in `CropDatabase` and
  `FishDatabase`: strawberry, tomato, pumpkin, and catnip crop contracts exist;
  the MVP river still returns `small_fish`, while the new `pond` spot carries
  Phase 6 fish variety.
- Phase 6.6 backend tool upgrade data is ready in `data/tools.json` and
  `ToolDatabase`: hoe, watering can, axe, pickaxe, and hand expose icons,
  action assets, upgrade costs, and repair cost helpers.
- Fishing frontend can call `FishDatabase.get_wait_time_seconds("river")` for
  bite timing and `FishDatabase.roll_reward("river")`, which returns a
  dictionary like `{ "item_id": "small_fish", "amount": 1 }`.
- Carrot crop frontend should use `seed_item_id`, `harvest_item_id`,
  `grow_time_seconds`, `stage_assets`, and `harvest_yield`.
- River fishing uses `min_wait_seconds`, `max_wait_seconds`, and weighted
  `rewards` entries with `item_id`, `weight`, `min_amount`, and `max_amount`.
- Backend smoke tests live in `build/test_backend.gd` and currently cover
  inventory stacking/removal/restore, `ItemDatabase` item lookup,
  `CropDatabase` crop lookup, `FishDatabase` river/pond reward rolls,
  `PetDatabase` pet definitions, `DecorationDatabase` decoration definitions,
  `DialogueDatabase` NPC dialogue, `ShopDatabase` buy/sell helpers,
  `ToolDatabase` upgrade costs, `Wallet`, and `SaveManager` local JSON round
  trips.

## Frontend Notes (Claude) — updated 2026-06-23 (MVP complete)

**MVP (Phases 1–5) is COMPLETE and verified.** `build/TestWorld.tscn` +
`build/test_backend.gd` both pass headless: world/collision (bridge-excluded
water), farming loop, fishing reward path (FishingSpot → FishDatabase →
Inventory), InventoryUI, and save/load round-trips (player position + inventory
via `SaveManager`, F5 save / F9 load / save-on-quit wired in `World.gd`).

**Phase 6 (post-MVP) is COMPLETE and verified.** Current coverage includes
build-mode decorations with cost/refund/save persistence, dog/duck/bunny ambient
pets, NPCs + dialogue UI, shop + wallet, five crop types, river + pond fishing,
and tool upgrades with saved tool levels.

## Frontend Notes (Claude) — updated 2026-06-23 (World Map Expansion)

**Expanded world map (DONE):** rewrote `scenes/world/World.gd` to paint a
**40×28** cozy map from code, region by region (forest TL, river+fishing TR,
path crossroads center, farm BL, home BC, empty BR), framed by a border of
trees. New helpers: `_paint(x,y,src)` (note: renamed from `_set` — `_set` is a
reserved `Node` virtual and breaks the script), `_build_river` (rectangular
water with directional grass edges/corners + a bridge), `_build_paths`,
`_build_tree_border`, `_build_water_collision`, `_build_fishing_spot`.
- **Water collision**: one box per water tile, **bridge row excluded**, so the
  river blocks the player except across the bridge. Completes task `1.5`.
- **Fishing spot**: a small bobber `Sprite2D` in group `fishing_spot` floats in
  the river — groundwork for `4.3` (`FishingSpot.tscn` interaction still TODO).
- **Tileset**: added 8 directional water tiles (edges + corners) to
  `MeowTileSet.tres` (source ids 7–14).
- Player/cat now spawn in the home area (tiles 20,23 / 19,23), set in `_ready`.
- **Cleaner placement + all-solid nature:** every nature prop now has the
  footprint invisible wall (like `tree_big`) via a single `_place_nature()` path.
  It enforces a min interval (`NATURE_GAP = 2` Chebyshev) between props and a
  `_reserved` set (all non-grass tiles + a 1-tile river margin + the spawn) so
  nature never clumps or lands on paths/water/soil/structures. Buildings/fences
  go down via `_place_structure()` which reserves their footprint first.
- ⚠️ **Fixed "player + cat disappear" bug:** the Player `Camera2D` limits in
  `Player.tscn` were still sized for the old 20×12 map (1280×768), so after the
  expansion the camera clamped to the top-left and the home-area spawn sat
  off-screen. `World._ready` now sets the camera limits from `MAP_W/MAP_H`
  (2560×1792). Guarded by a camera assertion in `build/TestWorld.tscn`.
- Verified: `build/TestWorld.tscn` smoke test (water=55, farm=12, fishing=1,
  spawn clear — all PASS) + clean headless boot + a faithful top-down preview.
- ⚠️ **Codex / asset pipeline bug:** the directional water tiles
  (`water_edge_*`, `water_corner_*`) shipped at **32×32** while every other tile
  is **64×64**. With a 64-px tileset grid this made Godot create empty/invalid
  tile textures (`image is empty`). I upscaled the 8 PNGs to 64×64
  (nearest-neighbor) so they render. **Please emit tiles at 64×64 at the source.**
  (Same family as the earlier "phantom blob" / misaligned-frame asset issues.)
- **Next obvious frontend piece:** `4.3/4.4` Fishing interaction — backend
  `FishDatabase` (`get_wait_time_seconds`, `roll_reward`) is ready, and the
  fishing-spot marker is already placed by the river.

**5.3 InventoryUI (DONE):**
- New `scenes/ui/InventoryUI.tscn` + `InventoryUI.gd` (a `CanvasLayer`, `layer
  10`). Added an instance to `World.tscn`.
- It is a **pure view of backend state**: reads `Inventory.get_all_items()` for
  counts and `ItemDatabase.get_item(id)` for each item's `name`/`icon`. Owns no
  item data. Subscribes to `Inventory.inventory_changed` and re-renders, so
  planting/harvesting updates the grid live.
- UI is built in code (centered `PanelContainer` → 4-col `GridContainer` of
  64×64 slots, icon + `xN` count badge, name in tooltip). Missing icons fall
  back gracefully via `ResourceLoader.exists`. Shows "(empty)" when no items.
- New input action **`inventory`** (key **I**, also **Esc** to close) in
  `project.godot`; toggled in `_unhandled_input`. Hidden at start.
- Verified headless: project boots clean (exit 0), UI builds and refreshes on
  the starter-seed grant without errors.
- **Next obvious frontend piece: Phase 4 Fishing scenes** — `FishingSpot.tscn`
  (4.3) can be built now; the catch interaction (4.4) is blocked on Codex's
  reward roll (4.2) + `fish.json` (4.1). Or Save wiring (5.4/5.5) once Codex
  lands `SaveManager` (5.1).

**Phase 3 — Farming (DONE, playable loop):**
- New `scenes/farming/`: `Crop` (growth visual), `FarmTile` (interact plot),
  `CropData` (frontend reader for `data/crops.json`).
- Loop: stand on a soil plot → press **interact** (E/Space) → plants a
  `carrot_seed` (consumed via `Inventory.remove_item`) → `Crop` advances through
  `stage_assets` over `grow_time_seconds` (30s) → when ready, interact again to
  harvest → `Inventory.add_item("carrot", harvest_yield)`.
- `World.gd` paints a 3×2 soil plot (tiles (5,9)–(7,10)) and drops a `FarmTile`
  on each; grants `STARTER_SEEDS = 10` carrot seeds at start (MVP convenience).
- Verified end-to-end headlessly: `seeds 10→9, ready=true, carrot 0→1`, plus a
  screenshot of the plot growing through stages.
- ⚠️ **3.4 "crop growth logic" is implemented frontend-side** in `Crop.gd` (a
  simple per-frame timer) since it's visual/scene behavior. Backend `crops.json`
  remains the source of truth for timing/stages/yield. **Codex: no CropDatabase
  autoload exists — `CropData` reads the JSON directly; add one if you want crop
  logic centralized like `ItemDatabase`.**
- **Next obvious frontend piece: InventoryUI (5.3)** so the player can SEE the
  seeds/carrots they hold — currently inventory changes are invisible in-game.

## Frontend Notes (Claude) — updated 2026-06-22

**Done so far (Phase 1 + 2, playable):**
- Godot **4.7** project runs clean (`godot --headless --path . --quit-after N` → exit 0).
  Verified visually via screenshots and a scripted collision test.
- `scenes/world/World.gd` paints the map, walls the edges, and spawns all
  decoration props from code via `_spawn_prop(tex, tile, solid, footprint, scale)`.
  **Every prop is a solid `StaticBody2D` obstacle** (collision layer 1) — trees,
  rocks, house, fence, pet bed, AND flowers. The wall is a **top-down footprint**:
  `_ground_footprint()` measures the x-extent of the asset's bottom slice (~30% of
  content height) so a tree blocks at its trunk/base, NOT its canopy — the player
  can walk near/behind the leaves. `WALL_MARGIN` (7px) buffer. **Bushes removed**
  (`bush.png` unused). Trees/rocks drawn ~1.3–1.4× bigger.
- Player + Cat use **`AnimatedSprite2D`** (not plain Sprite2D). Walk art is
  delivered as **horizontal 4-frame sheets, 512×128 (128px cells)**; idle = frame 0.
  Frame extraction lives in **`scenes/SpriteSheet.gd`** (`class_name SpriteSheet`,
  `build_frames()` + `facing_from()`), shared by `Player.gd` and `CatPet.gd`.
- Player/Cat use **feet-based Y-sort depth** (no z_index). Their sprites are
  offset up (`AnimatedSprite2D.offset.y = -28`) so the node origin sits at the
  feet; props sort by their base. Result: player is **in front when below** a
  prop, **behind when above or beside it** (ties resolve to the prop since props
  are added after the player). Collision/camera offsets were adjusted to match
  the feet-anchored origin.
- Player & cat sprites are shadow-free. Also cleaned a stray detached blob
  baked into the bottom of `cat_walk_right.png` (cleared rows ≥64).
- ⚠️ **Cat walk sheets shipped vertically misaligned per frame** — `cat_walk_left`
  feet were `[92,92,72,71]` (cat jumped mid-cycle) and `cat_walk_right` was
  `[62,61,62,61]` (floating). I normalized every cat frame to a common feet
  baseline (row 92) via a central-band feet detector. **Codex: the generator
  should emit frames with a consistent feet baseline per direction.**
- Cat follow movement is now **eased** (smoothed velocity + distance-scaled
  speed + anim `speed_scale`) instead of snapping on/off at the follow gap.
- ⚠️ **Several regenerated nature assets shipped with a stray "second blob"**
  baked into the same PNG (a floating grass tuft at the TOP of `rock.png`, and
  stray top specks in `flower.png` / `log.png`). I extracted just the main object
  by clearing the rows above it. **Codex: the asset generator is emitting these
  phantom clusters — please fix at the source so I don't keep hand-cleaning PNGs.**
- Prop placement now anchors by each texture's **`get_used_rect()` bottom**, not
  the canvas, so props with transparent padding (e.g. `tree_small.png`) sit ON
  the ground instead of floating / looking "cut off."
- The walk **sprite sheets are clean** — the "overlap/blur" artifact was the old
  code assigning the whole 512×128 sheet to one Sprite2D. Fixed by the
  AnimatedSprite2D extraction. If a stale squished render appears in the editor,
  let it re-import (the embedded Play may cache the old texture).

**⚠️ Reminders for Codex (backend / asset pipeline):**
1. **Keep walk sheets as horizontal N×N-frame strips.** `SpriteSheet.build_frames`
   assumes `FRAME = 128` square cells laid left-to-right. If the asset generator
   changes cell size or layout, update `FRAME` in `Player.gd`/`CatPet.gd`.
2. The dedicated 96×96 idles (`player_idle_down.png`, `cat_idle.png`) are **no
   longer used in-game** (idle now = walk-sheet frame 0). `cat_idle.png` is still
   the window icon in `project.godot`.
3. For **Save (5.1/5.4)**: the Player is in group `"player"`, is a
   `CharacterBody2D`, and exposes `position` directly — read it for
   `player_position`. Cat follows via group lookup, no hard reference needed.
4. Frontend is **ready to wire farming (3.5/3.7)** to `Inventory.add_item(...)`
   as soon as `FarmTile`/`Crop` scenes exist — blocked only on crop growth
   logic (3.4). Ping me when `grow_time_seconds`/`stage_assets` flow is final.
