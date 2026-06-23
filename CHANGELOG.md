# CHANGELOG.md — Meow Meow ~

Long development notes, verification logs, and asset generation history moved
out of [TASKS.md](TASKS.md) so the task board can stay a clean roadmap.

## 2026-06-23 — Phase 7.3 Weather System

- Added the `WeatherManager` autoload with stable weather IDs, daily forecast
  rolls, crop water/growth helpers, save data, and a small world overlay using
  the existing generated weather effect assets.
- Extended backend and world smoke tests to cover weather state, save/load
  round-trip, and the visible rain overlay.

## 2026-06-23 — Phase 7/8 Asset Pack

- Generated a 70-file Phase 7/8 asset pack with the `generate2dsprite` workflow.
- Coverage includes day/night, weather, season, achievement, and festival UI/FX
  assets for Phase 7.
- Coverage includes beach, mountain, mushroom forest, and snow terrain/props,
  ocean/winter/mountain fish icons, collectibles, crab assets, and eagle/penguin
  pet sprites for Phase 8.
- Outputs include `build/export_phase7_8_asset_pack.py`,
  `build/phase7_8_asset_pack_manifest.json`,
  `build/phase7_8_asset_pack_contact_sheet.png`, raw sheets under
  `build/generated-assets/raw/phase7_8/`, processed sheets under
  `build/phase7_8_sprite_pack/`, and final PNGs under `assets/`.
- Verified all 70 exported PNGs exist, open successfully, and are not empty.

## 2026-06-23 — Phase 6 Complete

- Phase 6.1 Decoration placement completed: build mode supports preview,
  validation, placement, removal, cost/refund through `Wallet`, collision, and
  save persistence.
- Phase 6.2 More pets completed: `CatPet.gd` is data-driven and the world places
  cat, dog, duck, and bunny behavior using `PetDatabase`.
- Phase 6.3 NPCs + dialogue completed: NPC scenes and DialogueUI read
  `DialogueDatabase` for greetings and dialogue lines.
- Phase 6.4 Shop + money completed: ShopUI, ShopTrigger, `ShopDatabase`, and
  `Wallet` support buy/sell behavior and persisted money.
- Phase 6.5 More crops / fish / map areas completed: multiple crop types, pond
  fishing, and additional fish reward tables are wired.
- Phase 6.6 Tool upgrades completed: workbench and ToolUpgradeUI spend coins and
  materials using `ToolDatabase`; tool levels persist in saves.
- Verification recorded in the previous task board: backend smoke tests,
  `build/TestWorld.tscn`, and clean headless boot passed after the Phase 6 work.

## 2026-06-23 — Phase 6 Asset Pack

- Generated a 123-file Phase 6 asset pack for pets, NPCs, portraits,
  decoration placement, extra decorations, shop UI, additional crops, fish
  icons, tools, collectibles, dialogue UI, and animated decoration support.
- Outputs included `build/export_phase6_asset_pack.py`,
  `build/phase6_asset_pack_manifest.json`,
  `build/phase6_asset_pack_contact_sheet.png`, raw generated sheets, prompt
  sidecars, and requested PNGs under the relevant `assets/` folders.
- Verification recorded in the previous task board: all requested filenames
  existed, PNG validation passed, no empty transparent outputs, backend smoke
  tests passed, world smoke tests passed, and clean headless boot passed.

## 2026-06-23 — Expanded World Map

- Expanded the map from 20x12 to 40x28 tiles in `scenes/world/World.gd`.
- Added home, farm, river/fishing, forest, main path, bridge, tree border,
  collision, and Y-sort-compatible prop placement using existing assets.
- Added directional water tiles to `MeowTileSet.tres` and corrected water-edge
  tile sizing to 64x64.
- Fixed camera limits so the player and cat remain visible after the larger map.
- Verification recorded in the previous task board: water collision count,
  farm plots, fishing spot, spawn safety, clean headless boot, and world smoke
  test passed.

## 2026-06-23 — Full Asset Pack

- Generated and normalized a 142-file cozy Godot 4 asset pack using the
  tile/prop workflow.
- Outputs included `build/full_asset_pack_manifest.json`,
  `build/full_asset_pack_contact_sheet.png`, raw generated sheets, prompts, and
  requested PNG assets across characters, pets, tiles, nature, farming, tools,
  fishing, buildings, vehicles, UI, shadows, effects, and animated folders.
- Verification recorded in the previous task board: exact requested filenames
  existed, PNG validation passed, no empty transparent outputs, animated sheets
  had expected frame dimensions, backend smoke tests passed, world smoke tests
  passed, and clean headless boot passed.

## 2026-06-23 — MVP Complete

- Phases 1-5 completed and verified: basic world, pet follower, farming,
  fishing, inventory, and local save/load.
- Backend systems completed: `Inventory`, `ItemDatabase`, `FishDatabase`,
  `PetDatabase`, `DecorationDatabase`, `DialogueDatabase`, `ShopDatabase`,
  `ToolDatabase`, `Wallet`, and `SaveManager`.
- Frontend systems completed: player movement, camera, cat follower, world map,
  farming scenes, fishing spot, InventoryUI, DialogueUI, ShopUI, and save/load
  wiring.
- Verification recorded in the previous task board: `build/TestWorld.tscn` and
  `build/test_backend.gd` passed headless.

## 2026-06-22 — Early Frontend Notes

- Phase 1 and Phase 2 became playable in Godot 4.7.
- Player and cat use `AnimatedSprite2D` with horizontal walk sheets and shared
  frame extraction through `scenes/SpriteSheet.gd`.
- Prop placement uses feet/base anchoring and Y-sort-compatible depth behavior.
- Early asset cleanup fixed misaligned cat walk frames and stray transparent PNG
  artifacts in several nature assets.
