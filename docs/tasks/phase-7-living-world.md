# Phase 7 — Living World

Goal: Make the world feel alive and dynamic.

## 7.1 Day & Night Cycle

| Task | Owner | Status |
|---|---|---:|
| TimeManager.gd | ⚙️ | ☑ autoload; advances time, phase/day signals |
| In-game clock UI | 🎨 | ☑ `TimeUI` clock readout (Day N + 12h clock) |
| Morning / Afternoon / Evening / Night | ⚙️ | ☑ `get_phase()` by hour |
| Screen tint changes | 🎨 | ☑ `TimeUI` full-screen tint, eased per phase |
| Ambient sounds by time | 🎨 | ☑ `Ambience` time-of-day music (day/night tracks, looped) |
| Time saved in save file | 🎨+⚙️ | ☑ `SaveManager` `time` {minutes, day} round-trip |

## 7.2 NPC Daily Schedule

| Task | Owner | Status |
|---|---|---:|
| NPC schedule data | ⚙️ | ☑ `data/npc_schedule.json` (home/work spots, sleep phase) |
| NPC movement between locations | 🎨 | ☑ roam "work" by day, "home" in evening, sleep home at night |
| NPC sleep at night | 🎨 | ☑ NPCs head home and rest during the night phase |
| NPC different dialogues depending on time | 🎨+⚙️ | ☑ `time_lines` in `dialogue.json` + DialogueUI shows the current phase's line |

## 7.3 Weather System

| Task | Owner | Status |
|---|---|---:|
| WeatherManager.gd | ⚙️ | ☑ autoload; stable IDs, signals, forecast rolls |
| Sunny weather | 🎨+⚙️ | ☑ default clear state |
| Cloudy weather | 🎨+⚙️ | ☑ world overlay uses generated cloud asset |
| Rain weather | 🎨+⚙️ | ☑ world overlay + waters crops |
| Storm weather | 🎨+⚙️ | ☑ world overlay + waters crops |
| Fog weather | 🎨+⚙️ | ☑ world overlay + slower crop multiplier |
| Weather affects crops | ⚙️ | ☑ public water/growth helper API |
| Weather saved in save file | 🎨+⚙️ | ☑ `SaveManager` weather round-trip |

## 7.4 Pet Friendship

| Task | Owner | Status |
|---|---|---:|
| Friendship level | ⚙️ | ☑ `PetFriendship` points→level (max 5), `friendship_changed` |
| Feed pet interaction | 🎨+⚙️ | ☑ press **F** near the follower to feed its favorite (+emote/toast) |
| Pet likes/dislikes | ⚙️ | ☑ favorite (from `pets.json`) +25, dislikes −5, normal +10 |
| Friendship UI | 🎨 | ☑ `FriendshipUI` hearts panel (reads `PetFriendship`) |
| Pet emotes | 🎨 | ☑ pets pop a happy/heart emote periodically |
| Pet passive abilities | ⚙️ | ☑ `has_passive_ability()` unlocks at level 3 |

## 7.5 Achievements

| Task | Owner | Status |
|---|---|---:|
| AchievementManager.gd | ⚙️ | ☑ autoload; `record_event`, `achievement_unlocked`, save |
| achievements.json | ⚙️ | ☑ definitions (event/mode/threshold) |
| First Harvest | ⚙️ | ☑ unlocks on first harvest (FarmTile hook) |
| Best Fisher | ⚙️ | ☑ unlocks after 10 fish (FishingSpot hook) |
| Animal Lover | ⚙️ | ☑ unlocks at friendship level 3 (auto from PetFriendship) |
| Achievement popup UI | 🎨 | ☑ `ToastUI` listens to `achievement_unlocked` (also save/festival toasts) |

## 7.6 Seasonal System

| Task | Owner | Status |
|---|---|---:|
| SeasonManager.gd | ⚙️ | ☑ autoload; season derived from day, `season_changed` |
| Spring | 🎨+⚙️ | ☑ active season + petals overlay |
| Summer | 🎨+⚙️ | ☑ active season + fireflies overlay |
| Autumn | 🎨+⚙️ | ☑ active season + leaves overlay |
| Winter | 🎨+⚙️ | ☑ active season + snowflakes overlay |
| Seasonal crop rules | ⚙️ | ☑ `get_crop_growth_multiplier()` (in/off-season, winter) |
| Seasonal visuals | 🎨 | ☑ `SeasonOverlay` tiles the season particle texture |

## 7.7 Festivals

| Task | Owner | Status |
|---|---|---:|
| FestivalManager.gd | ⚙️ | ☑ autoload; day schedule, active festival, save |
| Pet Festival | 🎨+⚙️ | ☑ backend + `FestivalUI` banner/claim |
| Fishing Festival | 🎨+⚙️ | ☑ backend + `FestivalUI` banner/claim |
| Flower Festival | 🎨+⚙️ | ☑ backend + `FestivalUI` banner/claim |
| Festival rewards | ⚙️ | ☑ `claim_reward()` grants coins + items once/day |
| Limited decorations | 🎨+⚙️ | ☑ festival-tagged decorations appear in build mode only during their festival |
