# Development Workflow — Meow Meow ~

> How AI agents (Codex / Claude Code) should work on this repo. Aligns with
> [../CLAUDE.md](../CLAUDE.md) (Claude = PM + Frontend), [../AGENTS.md](../AGENTS.md)
> (Codex = Backend), and the live board [../TASKS.md](../TASKS.md).

## Ground rules
- **Use small tasks.** One feature/system per change. Don't batch unrelated work.
- **Inspect files before editing.** Read the scene/script/data you're about to
  touch (and its callers) first. Say which files will change before editing.
- **Do not rewrite the whole project.** Make targeted edits; preserve working code.
- **Do not delete assets, scenes, or scripts** unless explicitly asked.
- **Keep it Godot 4 + GDScript**, simple and beginner-readable. Prefer autoload
  singletons for global systems.
- **No backend for MVP.** No Redis, Supabase, server, multiplayer, login, or
  cloud save. Local JSON save only (`user://save_v1.json`).
- **Respect ownership:** frontend owns `scenes/` + `assets/`; backend owns
  `scripts/` + `data/`. The UI/scenes *call into* backend APIs; they don't own data.
- **Run the parser/tests after changes** (see below). Record what passed/failed.
- **Update [../TASKS.md](../TASKS.md)** after each completed task (status + a note).

## Verify after every change (headless)
From the project root:
```bash
# 1. Does it boot / parse cleanly? (exit 0, no script/parse errors)
godot --headless --path . --quit-after 60

# 2. World + gameplay smoke test (collision, fishing, save/load)
godot --headless --path . res://build/TestWorld.tscn

# 3. Backend smoke test (inventory, item/fish/pet/decoration DBs, save)
godot --headless --path . -s build/test_backend.gd
```
If you add a system, add/extend a smoke test for it. Note: `SaveManager` writes
`user://save_v1.json`; delete it to test fresh-start behavior.

## Frontend ↔ backend contract
- Backend exposes small, stable public methods + signals; frontend consumes them.
- Example: `Inventory.add_item(id, amount)` / `inventory_changed` signal; the UI
  re-reads `Inventory.get_all_items()` on that signal.
- JSON shapes (`items/crops/fish/pets/decorations.json`, save file) are shared
  contracts — agree changes across both sides and record them in `TASKS.md`.

## Recommended task order
This is the stabilize-then-expand order. The MVP items (1–9) are already done and
verified; keep them green before moving on. Items 10–12 are the next frontier.
1. **Fix compile errors** — project must boot clean headless (exit 0).
2. **Stabilize world scene** — `World.tscn` builds without errors; map intact.
3. **Verify player movement** — 4-dir move + animation respond to input.
4. **Verify pet follower** — cat follows smoothly, never blocks the player.
5. **Verify map collisions** — walls + water block; bridge crosses; props solid.
6. **Farming** — plant → grow → harvest → inventory.
7. **Fishing** — interact → wait → reward → inventory.
8. **Inventory** — store + UI reflect changes live.
9. **Save/load** — player position + inventory persist and restore.
10. **Decoration placement** — player-driven build mode (data already exists).
11. **NPC dialogue** — needs NPC art + a dialogue data contract.
12. **Shop** — money system + buy/sell UI (coins + shop art already exist).

> When picking the *next* task, prefer ones not blocked on missing assets.
> Today that means **shop (12)** or **decoration placement (10)** before
> pets/NPCs (which need art).

## Definition of done (per task)
- Code compiles; relevant smoke test(s) pass headless.
- No assets/scenes deleted; changes are scoped to the task.
- `TASKS.md` updated (status + short note on what was verified).
- A one-line summary of files touched and why.
