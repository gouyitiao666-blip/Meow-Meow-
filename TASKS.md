# TASKS.md — Meow Meow ~ Roadmap

Shared roadmap between **Claude (Project Manager + Frontend)** and **Codex
(Backend)**. See [CLAUDE.md](CLAUDE.md), [AGENTS.md](AGENTS.md), and
[README.md](README.md).

**Owners:** 🎨 Frontend = Claude · ⚙️ Backend = Codex · 🎨+⚙️ Shared contract/work

**Status:** ☐ todo · ◐ in progress · ☑ done · 🔗 blocked

This file is the clean roadmap index. Detailed phase checklists live in
[`docs/tasks/`](docs/tasks/). Long development notes, testing logs, and asset
generation history live in [CHANGELOG.md](CHANGELOG.md).

---

## Phase Index

| Phase | Goal | Status | Checklist |
|---|---|---:|---|
| Phase 1 — Basic World | Establish the playable Godot world foundation. | ☑ done | [phase-1-basic-world.md](docs/tasks/phase-1-basic-world.md) |
| Phase 2 — Pet Follower | Add the first cozy companion. | ☑ done | [phase-2-pet-follower.md](docs/tasks/phase-2-pet-follower.md) |
| Phase 3 — Farming | Plant, grow, and harvest the MVP crop. | ☑ done | [phase-3-farming.md](docs/tasks/phase-3-farming.md) |
| Phase 4 — Fishing | Catch fish from the river using data-driven rewards. | ☑ done | [phase-4-fishing.md](docs/tasks/phase-4-fishing.md) |
| Phase 5 — Inventory + Save | Persist inventory and player progress locally. | ☑ done | [phase-5-inventory-save.md](docs/tasks/phase-5-inventory-save.md) |
| Phase 6 — Cozy Expansion | Add decorations, pets, NPCs, shop, content, and tools. | ☑ done | [phase-6-cozy-expansion.md](docs/tasks/phase-6-cozy-expansion.md) |
| Phase 7 — Living World | Make the world feel alive and dynamic. | ☑ done | [phase-7-living-world.md](docs/tasks/phase-7-living-world.md) |
| Phase 8 — World Expansion | Expand the cozy world with new areas and activities. | ☑ done | [phase-8-world-expansion.md](docs/tasks/phase-8-world-expansion.md) |
| Phase 9 — Kitchen, Crafting & Energy | Make food/goods + a gentle energy loop. | ☑ done | [phase-9-kitchen-crafting.md](docs/tasks/phase-9-kitchen-crafting.md) |
| Phase 10 — Quests, Skills & Collections | Direction + growth: quests, mail, skills, museum. | ☑ done | [phase-10-quests-skills.md](docs/tasks/phase-10-quests-skills.md) |
| Phase 11 — Home Interior & Community | Furnish your home + deepen the village. | ◐ core in; full house interior TODO | [phase-11-home-community.md](docs/tasks/phase-11-home-community.md) |
| Phase 12 — Polish & Game Feel | Audio, menus, transitions, juice, options. | ◐ pause/settings in | [phase-12-polish-game-feel.md](docs/tasks/phase-12-polish-game-feel.md) |
| Phase 13 — Endgame & Mastery | Mastery, automation, rare variants, 100%. | ☐ todo | [phase-13-endgame-mastery.md](docs/tasks/phase-13-endgame-mastery.md) |

---

## Shared Contracts

| Contract | Owner | Used By | Status |
|---|---|---|---:|
| `Inventory` public API + `inventory_changed` signal | ⚙️ | 🎨 UI, farming, fishing, shop | ☑ |
| Save file JSON shape and migrations | ⚙️ | 🎨 player/world/UI systems | ☑ |
| Item/crop/fish/pet/decoration/dialogue/shop/tool JSON schemas | ⚙️ | 🎨 scenes and UI | ☑ |
| Time/weather/season save fields | ⚙️ | 🎨 future UI, world tint, ambience | ☐ |
| NPC schedule/dialogue-by-time schema | ⚙️ | 🎨 future NPC movement/dialogue scenes | ☐ |
| Achievement event names and popup payload | ⚙️ | 🎨 future achievement UI | ☐ |

---

## Ownership Rule

- Claude owns `scenes/`, `assets/`, UI, input, animation, map presentation, and
  player-facing feel.
- Codex owns `scripts/`, `data/`, local save/load, JSON contracts, reward rolls,
  inventory/wallet/tool logic, and pure gameplay state.
- Shared tasks should define the backend contract first, then wire frontend
  scenes/UI against that contract.

