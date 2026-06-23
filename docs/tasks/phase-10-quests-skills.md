# Phase 10 — Quests, Skills & Collections

Goal: Give the cozy days direction and a sense of growth — small NPC requests,
a mailbox, skill levels that reward what you do, and a museum-style collection.

## 10.1 Quest System

| Task | Owner | Status |
|---|---|---:|
| `quests.json` (objective, reward, giver) | ⚙️ | ☑ |
| `QuestManager.gd` (track progress, complete, signal) | ⚙️ | ☑ |
| Quest log UI | 🎨 | ☑ in JournalUI (J) with Claim |
| NPC quest givers (turn-in via dialogue) | 🎨+⚙️ | ☑ talk to the giver to claim a completed quest |
| Objective tracking from gameplay events | 🎨+⚙️ | ☑ via GameEvents bus |
| Quest rewards (coins/items) | ⚙️ | ☑ |

## 10.2 Mailbox

| Task | Owner | Status |
|---|---|---:|
| Mailbox in the home area (interact) | 🎨 | ☑ UiTrigger |
| `MailManager.gd` + daily mail/letters | ⚙️ | ☑ daily letter on new day |
| Mail UI (read, claim attachments) | 🎨 | ☑ MailUI |
| Gift mail tied to friendship/festivals | 🎨+⚙️ | ◐ daily letters; event-gifted mail TODO |

## 10.3 Skills & XP

| Task | Owner | Status |
|---|---|---:|
| `SkillManager.gd` (farming/fishing/mining/foraging XP→level) | ⚙️ | ☑ |
| XP awarded from gameplay events | 🎨+⚙️ | ☑ via GameEvents |
| Skill UI (levels + progress) | 🎨 | ☑ in JournalUI |
| Level perks (yield/energy bonuses) | ⚙️ | ☑ farming yield + mining/foraging energy perks |
| Skills saved in save file | 🎨+⚙️ | ☑ |

## 10.4 Collections / Museum

| Task | Owner | Status |
|---|---|---:|
| `collections.json` (sets: fish, crops, treasures) | ⚙️ | ☑ |
| `CollectionManager.gd` (track donated items) | ⚙️ | ☑ |
| Museum building + donate interaction | 🎨+⚙️ | ☑ museum + MuseumUI |
| Collection UI (found/missing) | 🎨 | ☑ MuseumUI + JournalUI summary |
| Completion rewards | ⚙️ | ☑ coins when a set is completed |

## 10.5 Daily / Weekly Goals

| Task | Owner | Status |
|---|---|---:|
| Rotating daily goals | ⚙️ | ◐ quests cover repeatable goals; rotation TODO |
| Goal UI / toast on completion | 🎨 | ☑ quest-complete toast |
