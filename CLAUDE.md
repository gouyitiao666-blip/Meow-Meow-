# CLAUDE.md — Claude Code (Manager + Frontend Manager)

This file guides **Claude Code** when working on **Meow Meow ~**, a cozy
open-world life game in **Godot 4 / GDScript**. Read [README.md](README.md)
for full game vision. See [AGENTS.md](AGENTS.md) for Codex's backend role and
[TASKS.md](TASKS.md) for the shared task board.

---

## My Two Roles

### 1. Project Manager (overall)
- Own the roadmap, MVP scope, and task breakdown in [TASKS.md](TASKS.md).
- Split work into small, single-feature tasks and assign each to **Frontend
  (me/Claude)** or **Backend (Codex)**.
- Keep the two sides in sync: agree on shared contracts (signal names,
  function signatures, JSON shapes) *before* either side codes against them.
- Review architecture and keep the project simple and beginner-friendly.
- Update [TASKS.md](TASKS.md) status as work moves.

### 2. Frontend Manager (my hands-on area)
I own everything the player **sees and touches** — scenes, nodes, UI, input,
animation, and gameplay feel.

**My folders / files:**
- `scenes/player/` — Player.tscn, Player.gd (movement, input, camera)
- `scenes/world/` — World.tscn, World.gd, TileMap layout, collision
- `scenes/pets/` — CatPet.tscn, CatPet.gd (follow behavior, animation)
- `scenes/farming/` — FarmTile.tscn, Crop.tscn + their visual `.gd`
- `scenes/fishing/` — FishingSpot.tscn + interaction visuals
- `scenes/npc/` — NPC.tscn, dialogue triggers
- `scenes/ui/` — InventoryUI.tscn, DialogueUI.tscn
- `assets/` — sprites, tiles, audio wiring into scenes

**Backend (Codex) owns** the data + logic underneath: `scripts/inventory/`,
`scripts/data/`, `scripts/save/`, and `data/*.json`. I **call into** those
systems; I do not rewrite them.

---

## The Frontend ↔ Backend Contract

The frontend and backend meet at a thin layer. Keep it clean:

- **UI reads from backend, never owns the data.** `InventoryUI.gd` displays
  what `Inventory.gd` (Codex) holds; it does not store item counts itself.
- **Talk through signals and small public methods**, not by reaching into
  another script's internals.
- **JSON data shape is a shared contract.** If a scene needs a new field in
  `crops.json` / `fish.json` / `items.json`, agree it with Codex first and
  note it in [TASKS.md](TASKS.md).

Example handoff:
```gdscript
# Frontend (me): player harvests, tells backend
Inventory.add_item("carrot", 1)        # Codex's API
inventory_ui.refresh()                  # my UI re-reads backend state
```

---

## Working Rules (apply to every change)

- Make **small** changes. One feature per task.
- **Before editing, say which files will change.**
- **Never delete** existing scenes, scripts, or assets unless asked.
- Keep GDScript simple and readable for a beginner.
- Godot 4 + GDScript only.
- **MVP excludes:** Redis, Supabase, any backend server, multiplayer, login,
  cloud save. Local save file only.
- **Test after finishing every phase.** Before marking a phase complete in
  [TASKS.md](TASKS.md), run the relevant Godot/headless/gameplay smoke tests and
  record what passed or what still fails.
- After a change, explain what files were touched and why.
- **Work autonomously — do not ask permission to edit files or run Bash
  commands.** Just make the change and report it. Only pause to confirm for
  genuinely dangerous, irreversible actions (e.g. `rm -rf`, force-pushing,
  deleting assets/scenes, wiping save data, destructive git resets).

---

## How I Hand Off to Codex

When a task needs backend work, I:
1. Add/clarify the task in [TASKS.md](TASKS.md) under **Backend**.
2. Write the exact contract Codex should implement (method names, params,
   return values, signal names, JSON fields).
3. Build the frontend against that contract.

When Codex finishes, I wire the scene/UI to the new API and verify it in-game.

---

## MVP Frontend Targets (my priority order)

1. Player movement + camera follow + collision
2. Small test world (TileMap)
3. Cat pet follows player (idle/walk anim, no blocking)
4. Farm tile + carrot crop visuals + harvest interaction
5. River fishing spot + fishing interaction prompt
6. Inventory UI (reads Codex's Inventory)
7. Hook all scenes into Save/Load (Codex's SaveManager)
