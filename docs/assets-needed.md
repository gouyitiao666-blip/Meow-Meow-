# Assets Checklist — Meow Meow ~

> Status derived from the actual `assets/` folder (2026-06-24).
> Legend: **Existing** = file present · **Missing** = needed but absent ·
> **Unknown** = unclear purpose / can't confirm fit without seeing it in-game.
>
> **Note:** Phase 6–13 asset packs greatly expanded the library. Current art now
> covers pets/creatures, NPCs, crops, fish, buildings, interior pieces, shop and
> settings UI, upgraded tools, polish UI, and endgame/mastery concepts. Remaining
> work is mostly integration/code/scene wiring rather than missing PNG assets.

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
| Idle up / left / right (directional idles) | Existing (`player_idle_left/right/up.png`) |

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
| Bird / hamster | Existing (idle, sleep, happy emote, 4-dir walk) |
| Crab creature walk | Existing (4-dir walk + poses) |

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
| Interior floor/wall/door/window tiles | Existing |
| Endgame area tiles | Existing |

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
| Other crops (strawberry, tomato, pumpkin, corn, catnip) | Existing |
| Golden crop variants | Existing |

## Fishing assets (`assets/fishing/`)
| Asset | Status |
|---|---|
| Bobber | Existing |
| Fishing spot marker | Existing |
| Fishing rod icon | Existing |
| Small fish icon | Existing |
| Water splash | Existing |
| Rare/other fish art | Existing |
| Legendary fish art | Existing |

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
| Shop screen panel (dedicated) | Existing (`shop_panel.png`, buy/sell panels, tabs, quantity/detail controls) |
| Settings/options UI pieces | Existing |
| Controls/accessibility/save-slot UI pieces | Existing |
| Mastery/endgame UI pieces | Existing |

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
| Large regenerated building set | Existing (384×384 stereoscopic 3/4 building PNGs) |
| Phase 12/13 automation/endgame props | Existing |

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
| Shop screen / buy-sell UI | Existing |

## Tool assets (`assets/tools/`)
| Asset | Status |
|---|---|
| Hoe / watering can / axe / harvest / seed bag / hand icons | Existing |
| In-world tool sprites / upgraded tiers | Existing |

## Effects / animations
| Asset | Status |
|---|---|
| Effects (`assets/effects/`): harvest, plant, pickup, sparkle, splash, ripple, fish bite, friendship heart, speech bubble, exclamation | Existing |
| Shadows (`assets/shadows/`): small/medium/large | Existing |
| Animated PNGs (`assets/animated/`): water, sea wave, grass/flower/bush sway, fountain, lantern/mushroom-lamp glow, windmill, car | Existing (usage in-engine: Unknown) |
| Vehicles (`assets/vehicles/`): bicycle, cars, delivery van | Existing (gameplay role: Unknown) |
| Music tracks (`assets/audio/*.mp3`) | Existing (2 tracks, day/night) |

## Would-help (not blocking) — flagged by the visual-polish pass
| Asset | Why |
|---|---|
| Sand↔water **shoreline** edge/corner tiles | The beach ocean & snow pond are framed by sand/snow, but the sand→water seam is still a hard cut (the existing `water_edge_*` tiles are grass-bordered, so they look wrong on sand). A shoreline set would make the coast blend. |
| Grass→path and grass→soil **blend** edge tiles | The PNGs exist (`dirt_edge_*`, `farm_soil_edge/corner`) but aren't TileSet sources; adding them would soften those cuts. Out of scope for the polish pass (TileSet rework). |
| Weather **fog** status icon (`weather_fog_icon.png`) | TimeUI shows a weather icon; there's no fog icon, so fog currently falls back to the cloudy icon. |
| Note: `weather_*_overlay.png` (cloud/fog/rain/storm) | Small blob art unsuited to full-screen stretching — it produced muddy "stain" artifacts and is no longer used; weather is now a colour tint. Proper full-screen/animated weather art (or the `*_loop_sheet.png` variants wired as animation) could replace it later. |
