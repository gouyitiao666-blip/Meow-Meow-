# Assets Checklist — Meow Meow ~

> Status derived from the actual `assets/` folder (2026-06-23).
> Legend: **Existing** = file present · **Missing** = needed but absent ·
> **Unknown** = unclear purpose / can't confirm fit without seeing it in-game.
>
> **Note:** the Phase 6–11 asset packs greatly expanded the library — now present:
> all pets (cat/dog/duck/bunny/eagle/penguin), NPC villagers (idle/walk/portrait),
> biome tiles (beach/ocean/mountain/moss/snow/cave), ores/crab/shell/glowing-mushroom
> items, season/weather/festival effects, and 2 music tracks. Mostly-missing now:
> **interior wall/floor/door tiles**, and a few creature sheets (crab/bird).

## Player assets
| Asset | Status |
|---|---|
| Walk down/up/left/right sheets (`player_walk_*.png`) | Existing |
| Idle (`player_idle_down.png`) | Existing |
| Use hoe (`player_use_hoe.png`) | Existing |
| Use watering can (`player_use_watering_can.png`) | Existing |
| Pickup item (`player_pickup_item.png`) | Existing |
| Hold fishing rod (`player_hold_fishing_rod.png`) | Existing |
| Fishing pose (`player_fishing_pose.png`) | Existing |
| Idle up / left / right (directional idles) | Missing (idle = walk frame 0 today) |

## Pet assets (`assets/pets/`)
| Asset | Status |
|---|---|
| Cat walk down/up/left/right | Existing |
| Cat idle (`cat_idle.png`) | Existing |
| Cat sleep (`cat_sleep.png`) | Existing |
| Dog (idle + walk) | Existing |
| Duck (idle + walk) | Existing |
| Bunny (idle + walk) | Existing |
| Eagle (idle + walk) | Existing |
| Penguin (idle + walk) | Existing |
| Bird / hamster | Missing |

## Map tiles (`assets/tiles/`)
| Asset | Status |
|---|---|
| Grass (`grass_tile.png`) | Existing |
| Dirt path (`dirt_path_tile.png`) + dirt edges (top/bottom/left/right) | Existing |
| Stone path (`stone_path_tile.png`) | Existing |
| Sand (`sand_tile.png`) | Existing |
| Water (`water_tile.png`) + edge tile + 4 edges + 4 corners | Existing |
| Bridge (`bridge_tile.png`) | Existing |
| Farm soil (`farm_soil_tile.png`) + edge + corner | Existing |
| Wet soil (`wet_soil_tile.png`) | Existing |

## Nature assets (`assets/nature/`)
| Asset | Status |
|---|---|
| Tree big / tree small | Existing |
| Bush | Existing |
| Rock | Existing |
| Flower (+ white, + yellow) | Existing |
| Mushroom | Existing |
| Log / wood stump | Existing |

## Farming assets (`assets/farming/`)
| Asset | Status |
|---|---|
| Carrot seed icon | Existing |
| Carrot growth stages 1–3 | Existing |
| Carrot ready | Existing |
| Carrot icon (inventory) | Existing |
| Other crops (strawberry, tomato, pumpkin, corn, catnip) | Missing |

## Fishing assets (`assets/fishing/`)
| Asset | Status |
|---|---|
| Bobber | Existing |
| Fishing spot marker | Existing |
| Fishing rod icon | Existing |
| Small fish icon | Existing |
| Water splash | Existing |
| Rare/other fish art | Missing |

## UI assets (`assets/ui/`)
| Asset | Status |
|---|---|
| Inventory panel + slot + selected slot | Existing |
| Buttons (button/resume/save) | Existing |
| Dialogue box + nameplate + next arrow | Existing |
| Prompts (interact/pickup/plant/harvest/fish/talk/sleep) | Existing |
| Icons (coin/heart/energy/settings/pickup) | Existing |
| Tool hotbar + tool slot (+ selected) | Existing |
| Tile highlights (green/red) + selection cursor + build preview shadow | Existing |
| Pet emotes (happy/heart) + friendship hearts | Existing |
| Toast / item popup / pause panels | Existing |
| Shop screen panel (dedicated) | Unknown (panels exist; no explicit "shop" UI art) |

## Buildings (`assets/buildings/`)
| Asset | Status |
|---|---|
| Player house (+ small) | Existing |
| Farm house / barn / greenhouse / storage shed | Existing |
| Shop / pet shop / cafe / town hall / village house | Existing |
| Fence (+ corner / straight) | Existing |
| Wooden bridge / crate / post | Existing |
| Pet bed | Existing |
| Mailbox / signboard / trash bin | Existing |

## Decorations (assets live under `assets/buildings/` + `assets/nature/`)
| Asset | Status |
|---|---|
| Bench / outdoor chair / sofa / round table / picnic mat | Existing |
| Flower pot / lantern / mushroom lamp / fountain | Existing |
| (Defined in `data/decorations.json`) | Existing data |

## NPCs
| Asset | Status |
|---|---|
| Villager / NPC characters (farmer/fisher/shopkeeper/villager: idle + walk + portrait) | Existing |
| Dialogue UI art (box/nameplate/arrow) | Existing (in `assets/ui/`) |

## Shop assets
| Asset | Status |
|---|---|
| Shop building art | Existing (`assets/buildings/shop_building.png`, `pet_shop_building.png`) |
| Coin icon / coin drop | Existing (`assets/ui/coin_icon.png`, `assets/items/coin_drop.png`) |
| Shop screen / buy-sell UI | Unknown / Missing (no dedicated shop panel confirmed) |

## Tool assets (`assets/tools/`)
| Asset | Status |
|---|---|
| Hoe / watering can / axe / harvest / seed bag / hand icons | Existing |
| In-world tool sprites / upgraded tiers | Missing |

## Effects / animations
| Asset | Status |
|---|---|
| Effects (`assets/effects/`): harvest, plant, pickup, sparkle, splash, ripple, fish bite, friendship heart, speech bubble, exclamation | Existing |
| Shadows (`assets/shadows/`): small/medium/large | Existing |
| Animated PNGs (`assets/animated/`): water, sea wave, grass/flower/bush sway, fountain, lantern/mushroom-lamp glow, windmill, car | Existing (usage in-engine: Unknown) |
| Vehicles (`assets/vehicles/`): bicycle, cars, delivery van | Existing (gameplay role: Unknown) |
| Music tracks (`assets/audio/*.mp3`) | Existing (2 tracks, day/night) |
