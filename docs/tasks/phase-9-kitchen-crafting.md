# Phase 9 — Kitchen, Crafting & Energy

Goal: Give the player things to *make* and a gentle daily rhythm. Turn raw
materials (crops, fish, ore, shells, mushrooms) into cooked food and crafted
goods, and add a soft energy loop that food restores.

## 9.1 Crafting System

| Task | Owner | Status |
|---|---|---:|
| `recipes.json` (inputs → output, station) | ⚙️ | ☑ |
| `RecipeDatabase.gd` autoload (lookup, can_craft, craft) | ⚙️ | ☑ |
| CraftingUI (recipe list, ingredients, Craft button) | 🎨 | ☑ |
| Crafting station in the world (interact to open) | 🎨 | ☑ kitchen station near home |
| Recipe gating by station type | 🎨+⚙️ | ◐ `station` field + `get_by_station`; one station so far |

## 9.2 Cooking

| Task | Owner | Status |
|---|---|---:|
| Cooking recipes (crops/fish → dishes) | ⚙️ | ☑ |
| Kitchen station | 🎨 | ☑ |
| Dish items (food) with energy value | ⚙️ | ☑ food `energy` in `items.json` |
| Eat food → restore energy | 🎨+⚙️ | ☑ `EnergyManager.eat()` |
| Recipe discovery / unlocks | ⚙️ | ☐ (all recipes available now) |

## 9.3 Energy / Stamina

| Task | Owner | Status |
|---|---|---:|
| `EnergyManager.gd` (max, spend, restore, signal) | ⚙️ | ☑ |
| Energy bar UI | 🎨 | ☑ `EnergyUI` |
| Actions cost energy (mining/foraging) | 🎨+⚙️ | ☑ GatherNode spends energy |
| Daily energy reset (on new day) | ⚙️ | ☑ refills on `day_changed` |
| Energy saved in save file | 🎨+⚙️ | ☑ `SaveManager` energy round-trip |
| Pass-out / low-energy feedback | 🎨 | ◐ "Too tired" toast when out of energy |

## 9.4 Material Sinks

| Task | Owner | Status |
|---|---|---:|
| Ore → tool-upgrade materials (ties 6.6) | 🎨+⚙️ | ☑ hoe Lv3 needs rare_blue_ore |
| Crafted decorations feed build mode (ties 6.1) | 🎨+⚙️ | ☑ furniture decorations placeable |
| Sell cooked dishes at the shop (ties 6.4) | ⚙️ | ☑ general store buys pet_food |
