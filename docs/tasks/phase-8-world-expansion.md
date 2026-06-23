# Phase 8 — World Expansion

Goal: Expand the cozy world with new areas and activities.

Biomes are painted as a band along the bottom of the 52×36 map in `World.gd`
(`_build_biomes`), using the biome tiles added to `MeowTileSet.tres`. Gathering
uses the reusable `scenes/world/GatherNode.gd` (mine ore / forage plants).

## 8.1 Beach Area

| Task | Owner | Status |
|---|---|---:|
| Beach map | 🎨 | ☑ sand area + ocean strip (bottom-left) |
| Ocean fishing | 🎨+⚙️ | ☑ `ocean` spot in `fish.json` + FishingSpot on the shore |
| Shell collection | 🎨+⚙️ | ☑ shells are an ocean catch (item `shell`) |
| Crabs | 🎨+⚙️ | ☑ `crab` item + ocean catch |
| Beach decorations | 🎨+⚙️ | ☑ shell pile + coral/starfish decor |

## 8.2 Mountain Area

| Task | Owner | Status |
|---|---|---:|
| Mountain map | 🎨 | ☑ rocky ground + stone path |
| Rare ores | 🎨+⚙️ | ☑ ore items + mineable rocks (GatherNode) |
| Cave entrance | 🎨 | ☑ cave-floor patch in the mountain |
| Eagle pet | 🎨+⚙️ | ☑ `eagle` in `pets.json` + ambient eagle |
| Mountain decorations | 🎨+⚙️ | ☑ rocks + pine shrub |

## 8.3 Mushroom Forest

| Task | Owner | Status |
|---|---|---:|
| Mushroom biome | 🎨 | ☑ moss ground area |
| Glowing mushrooms | 🎨 | ☑ mushroom-lamp + glowing cluster props |
| Rare plants | 🎨+⚙️ | ☑ forage `glowing_mushroom` (GatherNode) + giant mushroom decor |
| Bunny village | 🎨+⚙️ | ☑ bunny stump house + village house + bunnies |
| Mushroom decorations | 🎨+⚙️ | ☑ lamps + mushrooms |

## 8.4 Snow Area

| Task | Owner | Status |
|---|---|---:|
| Snow biome | 🎨 | ☑ snowfield area |
| Frozen pond | 🎨 | ☑ frozen water patch with collision + marker |
| Winter fish | 🎨+⚙️ | ☑ `frozen_pond` spot in `fish.json` + FishingSpot |
| Snow effects | 🎨 | ☑ icy-crystal decor + winter season/weather overlays |
| Penguin pet | 🎨+⚙️ | ☑ `penguin` in `pets.json` + ambient penguin |

## Follow-ups (polish, not blocking)
- Crab as a walking beach creature (currently a catch) — needs a crab sprite sheet.
- Mining/foraging tie-ins: ores for tool upgrades, rare plants for recipes.
- Cave interior as its own sub-area.
