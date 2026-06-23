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
| First-time hint toasts (controls, goals) | 🎨 | ☐ |
| Controls help panel | 🎨 | ☐ |

## 12.4 Game Feel / Juice

| Task | Owner | Status |
|---|---|---:|
| Day-transition fade (sleep) | 🎨 | ☑ fade-to-black on sleep |
| Action particles (harvest/plant/splash/sparkle) | 🎨 | ☑ `Effects` autoload on harvest/plant/fish/gather |
| Pickup popups / floating text | 🎨 | ◐ toasts exist |
| Player action poses (fish/hoe/mine/pickup) | 🎨 | ☑ `Player.play_action()` |
| Subtle camera shake on big events | 🎨 | ☐ |

## 12.5 Controls & Accessibility

| Task | Owner | Status |
|---|---|---:|
| Controller / gamepad support | 🎨 | ☐ |
| Rebindable keys | 🎨+⚙️ | ☐ |
| Text size / colorblind-friendly palette | 🎨 | ☐ |

## 12.6 Save Slots

| Task | Owner | Status |
|---|---|---:|
| Multiple save slots + title/new-game screen | 🎨+⚙️ | ☐ |
