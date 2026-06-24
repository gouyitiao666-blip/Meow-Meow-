# Visual Rules for Meow Meow ~

Keep the world cozy, readable, and consistent. Future Claude/Codex changes should
follow these so the look doesn't drift. Established in the visual-polish pass.

## Scale Rules
- **Buildings > humans.** Buildings should feel enterable — much bigger than the
  player. Building art is 384px native and is normalized to a ~128px baseline
  (`PROP_BASELINE` in `World.gd`), then a per-prop `scale` lifts houses/shops
  above human height. Don't render a building at human size.
- **Humans are the top living tier.** Player = scale `1.0`; NPCs ≈ `0.92`
  (`NPC.SCALE`). NPCs and the player read as the same size class.
- **Animals < humans.** All pets share 128px frames, so per-animal scale lives in
  `CatPet.WORLD_SCALE` (cat 0.55, dog 0.62, duck 0.42, bunny 0.40, eagle 0.55,
  penguin 0.52, crab 0.38, hamster 0.32). A cat is roughly half the player; a dog
  is close to but under the player. Never bigger than a building.
- **Trees > humans**, but shorter than big buildings (handled by `_place_nature`
  scales ~1.3–1.4 on 128px art).
- **Fishing / action poses match the player body.** Pose art is 64px; `Player.play_action`
  scales it to the 128px body (`s = 128 / height`) and feet-aligns it
  (`offset = -28 / s`). Equipment/poses must not look tiny or giant.
- **Crops/decorations stay believable** — small relative to humans; a crop is
  ankle/knee height, a fence/bench/lamp is human-scaled.
- Use **named scale constants**, not magic numbers, and comment the choice.

## Layering Rules
- The world root (`World.tscn`) has `y_sort_enabled = true`. Everything that
  stands on the ground (player, NPCs, pets, props, gather nodes) is **anchored at
  its feet/base** so y-sort orders them by screen-Y: lower on screen = in front.
- When you scale a character, keep its node origin at the feet (the shared
  `offset = -28` pivot already does this at any scale — don't move it).
- Reserve `z_index` for true overlays only (pet emote, build-mode ghost/cursor).
  Don't use it to fake depth between ground actors.
- "Set invisible" means hide **debug** visuals (collision shapes, placeholder
  boxes, markers) — never real player/NPC/animal/crop/building/decoration/UI
  sprites. Collision shapes only render with the editor's "Visible Collision
  Shapes" debug flag, so a normal/exported run shows none.

## Collision Rules
- **Every world prop is solid** (invisible wall): trees, rocks, logs, bushes,
  flowers, mushrooms, buildings, fences, lamps, crates, tables, gather nodes,
  water. The wall is the art's **base footprint only** (the bottom slice), never
  the full roof/canopy — so a tree blocks its trunk, a building its foundation,
  a flower its little stem, and a path tile under a building stays walkable.
- Footprints are sized from the art and stay off the paths (props are never
  placed on path/soil tiles), so there are no invisible walls mid-path.
- **Pets are non-solid.** The follower cat and ambient animals (dog/duck/bunny/
  etc.) never block the player — a small roaming solid body reads as a "moving
  invisible wall". NPCs keep a small solid footprint (intentional, so you bump
  into a person, not a tiny pet).
- **Water** blocks movement except bridges / intended crossings.
- Collision shapes are debug-only visuals (editor "Visible Collision Shapes");
  they never render in a normal/exported run, so there's nothing to hide in-game.
- There is **no car/vehicle** in the world (only unused `assets/vehicles/` art).
  If one is added later, give it a body-only collision box, not a map-spanning shape.

## Movement Rules
- NPCs and ambient animals roam only on believable ground. They validate every
  wander target (and each step) against `World.is_walkable_world_pos()`, which
  rejects water, building footprints, fences, and nature.
- Each actor stays near its home/work spot (`WANDER_RADIUS`), so it reads as
  belonging to its zone (farmer→farm, fisher→river, duck→riverbank, shopkeeper→
  shop, villager→village, biome animals→their biome).
- The follower cat is the deliberate exception: non-physics, never blocks the
  player (CLAUDE.md 2.4).

## Map Transition Rules
- **Grass → sand → sea**, never grass directly on sea. Ocean/beach and the snow
  frozen-pond water are **inset one tile inside their sand/snow band** so the
  ground always frames the water.
- River and central pond use grass-bordered water edge/corner tiles for a soft
  bank.
- Avoid harsh biome color cuts where soft edge tiles exist; where they don't
  (sand↔water shoreline, grass↔path, grass↔soil), see
  [assets-needed.md](assets-needed.md) for the edge tiles that would help.

## Weather & Seasons (full-screen overlays)
- Weather is a **gentle full-screen colour wash** (`World.WEATHER_TINTS`), not a
  stretched texture. The old `weather_*_overlay.png` blobs, scaled to fill the
  screen, blended into muddy brown "stains" over the grass — don't reintroduce
  that. A subtle tint per state (cloudy/rain/storm/fog) is enough mood.
- The season overlay tiles the **scattered-petal/leaf art from `assets/effects/`**
  at low alpha (drifting particles). Only tile art that is mostly transparent
  specks; never stretch/tile a solid blob full-screen (that's how stains happen).

## UI
- A global cozy theme (`scenes/ui/MeowTheme.tres`, registered via
  `project.godot → gui/theme/custom`) skins every panel/button/label.
- **Generic overlays use a warm "parchment" flat panel** (the theme's
  `StyleBoxFlat`). It never distorts at any size — used by Tool/Crafting/Journal/
  Mail/Museum/Festival/Toast/Pause and anything without a bespoke frame.
- **Key overlays use the decorative `assets/ui/` frames** via `scenes/ui/UiSkin.gd`
  (`apply_panel` / `apply_slot`): Inventory (`inventory_panel`), Shop
  (`shop_panel`), Dialogue (`dialogue_box`), Title (`title_screen_panel` banner).
- **Showing a framed asset, not a cropped one:** these frames are ornate (≈45px
  wooden border + corner flowers/heart). Always set the panel's **content margin
  ≥ the frame thickness** (~50px) so the content sits in the cream centre and the
  decorations are never overlapped/cut; size the panel generously so corner art
  isn't squished. (`UiSkin.apply_panel(panel, path, content_margin, tex_margin)`.)
- **Buttons use a warm flat box** (`UiSkin.button_box` / theme `StyleBoxFlat`),
  *not* `button.png`: the decorative button art centres its shape inside
  transparent padding, so 9-slicing collapses it to near-invisible. Tint flat
  buttons for meaning (shop buy = green, sell = amber).
- Rows that hold buttons (shop) give the buttons a fixed min-width and the label
  `clip_text`, so nothing overflows/crops the panel.
- Prefer framed panels over text floating on the world (small interaction
  prompts are the only exception).
