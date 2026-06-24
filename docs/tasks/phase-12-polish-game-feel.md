# Phase 12 — Polish & Game Feel

Goal: Make the existing systems feel great — sound, menus, transitions, juice,
onboarding, and options. No new mechanics; this is the layer that ties it
together.

## 12.1 Audio

| Task | Owner | Status |
|---|---|---:|
| Time-of-day music | 🎨 | ☑ `Ambience` (Phase 7) |
| Master volume + mute | 🎨+⚙️ | ☑ in pause menu |

> SFX dropped from scope (no sound-effect assets); action *visual* effects cover
> feedback instead (12.4).

## 12.2 Pause & Options Menu

| Task | Owner | Status |
|---|---|---:|
| Pause menu (Esc): Resume / Save | 🎨 | ☑ `PauseUI` |
| Settings: volume slider + mute | 🎨+⚙️ | ☑ master volume + mute |
| `get_tree().paused` while open | 🎨 | ☑ |
| Quit to desktop | 🎨 | ☑ |

## 12.3 Onboarding / Tutorial

| Task | Owner | Status |
|---|---|---:|
| First-time hint toasts (controls, goals) | 🎨 | ☑ `OnboardingHints` on a fresh game |
| Controls help panel | 🎨 | ☐ asset support present (`controls_help_panel.png`, `controls_diagram_card.png`) |

## 12.4 Game Feel / Juice

| Task | Owner | Status |
|---|---|---:|
| Day-transition fade (sleep) | 🎨 | ☑ fade-to-black on sleep |
| Action particles (harvest/plant/splash/sparkle) | 🎨 | ☑ `Effects` autoload on harvest/plant/fish/gather |
| Pickup popups / floating text | 🎨 | ◐ toasts exist |
| Player action poses (fish/hoe/mine/pickup) | 🎨 | ☑ `Player.play_action()` |
| Subtle camera shake on big events | 🎨 | ☐ visual icon/effect support present |

## 12.5 Controls & Accessibility

| Task | Owner | Status |
|---|---|---:|
| Controller / gamepad support | 🎨 | ☑ `ControllerSetup` (see 14.3) |
| Rebindable keys | 🎨+⚙️ | ☐ asset support present |
| Text size / colorblind-friendly palette | 🎨 | ☐ asset support present |

## 12.6 Save Slots

| Task | Owner | Status |
|---|---|---:|
| Multiple save slots + title/new-game screen | 🎨+⚙️ | ☐ asset support present |

## 12.7 Cozy UI skin & world readability (visual-polish pass)

| Task | Owner | Status |
|---|---|---:|
| Global cozy theme for all panels/buttons/labels | 🎨 | ☑ `scenes/ui/MeowTheme.tres` via `gui/theme/custom` |
| Bespoke panel/slot/button art: Inventory, Dialogue, Shop | 🎨 | ☑ `scenes/ui/UiSkin.gd` |
| Status icons: time-of-day / weather / season / energy | 🎨 | ☑ TimeUI + EnergyUI |
| Relative scale fixes (animals < humans; poses match body) | 🎨 | ☑ `CatPet.WORLD_SCALE`, `NPC.SCALE`, `Player.play_action` |
| NPC/animal movement constrained to walkable ground | 🎨 | ☑ `World.is_walkable_world_pos` |
| Grass→sand→sea transitions (water framed) | 🎨 | ☑ beach/snow water inset |
| Weather "stain" overlay → gentle colour tint | 🎨 | ☑ `World.WEATHER_TINTS` |
| Visual rules documented | 🎨 | ☑ [docs/visual-rules.md](../visual-rules.md) |
