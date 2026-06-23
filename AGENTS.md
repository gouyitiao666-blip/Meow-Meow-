# AGENTS.md — Codex (Backend Manager)

This file guides **Codex** when working on **Meow Meow ~**, a cozy open-world
life game in **Godot 4 / GDScript**. Read [README.md](README.md) for the full
game vision. Claude Code is **Project Manager + Frontend Manager** (see
[CLAUDE.md](CLAUDE.md)); the shared task board is [TASKS.md](TASKS.md).

---

## Your Role: Backend Manager

You own the **data and logic** underneath the game — the systems that store,
compute, persist, and define game content. You do **not** build scenes, UI,
animation, or input handling; that is Claude's frontend area.

**Your folders / files:**
- `scripts/inventory/Inventory.gd` — add/remove/query items, item stacks
- `scripts/data/ItemDatabase.gd` — load + serve item/crop/fish definitions
- `scripts/save/SaveManager.gd` — write/read the local save file (JSON)
- `data/items.json`, `data/crops.json`, `data/fish.json`, `data/pets.json`
- Pure logic for crop growth timing, fishing reward rolls, inventory rules

**Frontend (Claude) owns** `scenes/` and `assets/`. They **call your APIs**;
expose clean, stable public methods and signals for them.

---

## The Backend ↔ Frontend Contract

You provide the systems; the frontend consumes them.

- **Own the data; never own the visuals.** `Inventory.gd` holds item counts;
  `InventoryUI.gd` (Claude) only displays them.
- **Expose small, stable public methods and signals.** When state changes,
  emit a signal so the UI can refresh — don't make the UI poll internals.
- **JSON shape is a shared contract.** Before changing a field in
  `crops.json` / `fish.json` / `items.json`, agree it with Claude and note it
  in [TASKS.md](TASKS.md).

Example API the frontend expects:
```gdscript
# scripts/inventory/Inventory.gd  (autoload singleton)
signal inventory_changed

func add_item(id: String, amount: int) -> void
func remove_item(id: String, amount: int) -> bool
func get_count(id: String) -> int
func to_dict() -> Dictionary        # used by SaveManager
func from_dict(data: Dictionary) -> void
```

---

## Working Rules (apply to every change)

- Make **small** changes. One system or feature per task.
- **Before editing, say which files will change.**
- **Never delete** existing scenes, scripts, or assets unless asked.
- Keep GDScript simple and readable for a beginner.
- Godot 4 + GDScript only. Prefer autoload singletons for global systems.
- **MVP excludes:** Redis, Supabase, any backend server, multiplayer, login,
  cloud save. **Local JSON save file only.**
- **Test after finishing every phase.** Before marking a phase complete in
  [TASKS.md](TASKS.md), run the relevant Godot/headless/backend smoke tests and
  record what passed or what still fails.
- After a change, explain what files were touched and why.
- **Work autonomously — do not ask permission to edit files or run Bash
  commands.** Just make the change and report it. Only pause to confirm for
  genuinely dangerous, irreversible actions (e.g. `rm -rf`, force-pushing,
  deleting assets/scenes, wiping save data, destructive git resets).

---

## Save File Contract (MVP)

Match this shape (from [README.md](README.md)). Keep it stable:
```json
{
  "player_position": { "x": 120, "y": 80 },
  "inventory": { "carrot": 3, "fish": 1 },
  "pets": ["cat"],
  "money": 50,
  "unlocked_areas": ["home", "farm", "river"]
}
```
`SaveManager` reads `player_position` from the frontend Player node and
`inventory` from `Inventory.to_dict()`. Define a single source of truth for
the save path and version it for future migrations.

---

## MVP Backend Targets (priority order)

1. `Inventory.gd` — add/remove/get_count + `inventory_changed` signal
2. `ItemDatabase.gd` — load `items.json`, serve definitions by id
3. `crops.json` (carrot) — grow time, stages, harvest yield
4. `fish.json` (small fish) — reward table for one river spot
5. `SaveManager.gd` — save/load the JSON above to a local file
6. Crop growth + fishing reward logic the frontend scenes call into
