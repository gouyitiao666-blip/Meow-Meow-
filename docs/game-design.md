# Game Design — Meow Meow ~

> Source of truth for the *vision*. For what is actually built, see
> [current-status.md](current-status.md). For the live task board, see
> [../TASKS.md](../TASKS.md).

## Game Name
**Meow Meow ~**

## Genre
Cozy open-world **life simulation / sandbox**. No combat. Single-player.

## Core Feeling
Calm, warm, slow-living. The player should feel like they *live inside a small
peaceful world* — free to choose what to do each day (farm, fish, wander, decorate,
hang out with a pet) with no pressure, timers, or fail states.

## Visual Style
- Cute, soft, colorful, hand-drawn-feeling 2D.
- Top-down / light 2.5D-isometric framing.
- 64×64 tile grid. Props anchored at their base and depth-sorted with Y-sort so
  the player passes correctly in front of / behind objects.
- Rounded, friendly shapes; bright cozy palette.

## Player Fantasy
"I have a little cottage in a cozy village. My cat follows me around. I tend my
garden, fish by the river, gather flowers and wood, and slowly make the place
my own."

## Main Gameplay Loop
1. Walk around the world (player + camera follow), cat pet trailing along.
2. Plant seeds on farm soil → crops grow over time → harvest into inventory.
3. Fish at the river spot → wait for a bite → catch fish into inventory.
4. Gather resources / collect items.
5. (Future) Spend money at a shop, decorate the home, meet NPCs, unlock areas.
6. Save progress locally and pick up where you left off.

## Core Features
- 4-direction player movement with walk animation + camera follow.
- A cat pet that follows the player smoothly and never blocks them.
- A tile-based open-world map (forest, river+bridge, farm, home, paths).
- Farming: plant → grow → harvest (carrot in MVP).
- Fishing: interact → wait → reward roll → catch (small fish in MVP).
- Inventory backed by a global store, with a UI panel.
- Local JSON save/load (player position + inventory).

## MVP Scope (built)
- Top-down player movement + camera follow.
- One open-world test map with wall/water collision.
- One cat pet follower (idle/walk).
- One farm area, one crop (carrot): plant, grow, harvest into inventory.
- One river fishing spot: interact, wait, catch a small fish into inventory.
- Simple inventory system + inventory UI.
- Local save file (no backend).

**Explicitly NOT in MVP:** multiplayer, online accounts, cloud save, Redis,
Supabase, any backend server, leaderboards, marketplace, complex NPC systems.

## Future Expansion Ideas (post-MVP "Cozy Expansion")
- **More pets:** dog, duck, bunny, bird, hamster; friendship levels, emotes,
  helper abilities.
- **Decoration / build system:** player-placed fences, benches, lanterns,
  flower pots, pet beds, bridges, etc.
- **NPCs + dialogue:** villagers, a dialogue UI, simple quests.
- **Shop + money:** buy seeds/decorations, sell crops/fish using coins.
- **More content:** new crops (strawberry, tomato, pumpkin, corn, catnip),
  rarer fish, new map areas (beach/pond), unlockable regions.
- **Tool upgrades:** hoe, watering can, axe, fishing rod tiers.
- **Ambience:** day/night, weather, audio/music, animated tiles & effects.

## Design Guardrails
- Stay cozy: no combat, no punishment, no urgency.
- Keep it beginner-readable Godot 4 / GDScript.
- Local-first; only consider a backend if/when online features are truly needed.
