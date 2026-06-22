# Meow Meow ~

**Meow Meow ~** is a cozy open-world life adventure game where the player can freely explore a cute top-down / isometric world, take care of pets, farm crops, fish by the river, collect resources, decorate their home area, and enjoy peaceful daily life.

The game focuses on freedom, relaxation, and exploration instead of combat.

---

## Game Vision

The main feeling of **Meow Meow ~** is:

> Walk freely in a cute world, live slowly, take care of pets, farm, fish, decorate, and discover small surprises.

The world should feel soft, colorful, warm, and alive.  
The player should feel like they are living inside a small peaceful open world.

Inspired by cozy open-world and life-simulation games, **Meow Meow ~** aims to create a relaxing experience where players can choose what they want to do each day.

---

## Core Gameplay

Players can:

- Explore a cute open-world map
- Farm crops and harvest items
- Fish near rivers, ponds, or beaches
- Own pets that follow the player
- Collect flowers, wood, stones, fish, and other resources
- Decorate the home area
- Talk to NPCs
- Unlock new areas
- Upgrade tools
- Build a peaceful daily routine

---

## MVP Scope

The first version should be small and playable.

### MVP Features

- Top-down player movement
- Camera follows the player
- Small open-world test map
- One cat pet that follows the player
- One farm area
- Plant one crop
- Crop grows over time
- Harvest crop into inventory
- One river fishing spot
- Basic fishing interaction
- Simple inventory system
- Local save file

### Not Included in MVP

These should **not** be built first:

- Multiplayer
- Online accounts
- Cloud save
- Redis
- Supabase
- Backend server
- Large world map
- Complex NPC system
- Marketplace
- Leaderboards

The first goal is to make a simple local single-player game that feels fun and cozy.

---

## Tech Stack

### Current Recommended Stack

| Part | Technology |
|---|---|
| Game Engine | Godot 4 |
| Language | GDScript |
| Map System | Godot TileMap / TileMapLayer |
| Data | JSON files or Godot Resources |
| Save System | Local save file |
| Version Control | Git + GitHub |
| AI Coding Tools | Codex + Claude Code |

### Why This Stack?

Godot 4 is a good fit because **Meow Meow ~** is a 2D cozy open-world game.  
It supports TileMap, scenes, animation, UI, player movement, pet following, and local saving without needing a backend.

GDScript is recommended because it is simple, beginner-friendly, and works naturally with Godot.

---

## Backend Decision

For the MVP, this project does **not** need Redis, Supabase, Firebase, or any backend.

Use local save files first.

Example save data:

```json
{
  "player_position": { "x": 120, "y": 80 },
  "inventory": {
    "carrot": 3,
    "fish": 1
  },
  "pets": ["cat"],
  "money": 50,
  "unlocked_areas": ["home", "farm", "river"]
}
```

A backend can be added later only if the game needs:

- User login
- Cloud save
- Online friends
- Multiplayer
- Online pet sharing
- Leaderboards

---

## Main Systems

### Player System

The player can move around the world and interact with objects.

Responsibilities:

- Movement
- Interaction
- Tool usage
- Inventory access
- Camera follow

---

### Pet System

Pets are an important part of **Meow Meow ~**.

MVP pet:

- One cat pet follows the player
- Cat has idle and walking behavior
- Cat stays near the player
- Cat does not block the player

Future pet ideas:

- Cats
- Dogs
- Ducks
- Bunnies
- Birds
- Hamsters

Possible future abilities:

- Find hidden items
- Help collect resources
- Give small buffs
- React with emojis
- Gain friendship level

---

### Farming System

Basic farming loop:

1. Player gets seed
2. Player plants seed on soil
3. Crop grows over time
4. Player harvests crop
5. Crop goes into inventory

MVP crop:

- Carrot

Future crops:

- Strawberry
- Tomato
- Pumpkin
- Corn
- Flower
- Catnip

---

### Fishing System

Basic fishing loop:

1. Player stands near water
2. Player presses interact
3. Fishing starts
4. Player waits for a bite
5. Player catches a fish
6. Fish goes into inventory

MVP fishing reward:

- Small Fish

Future fishing rewards:

- Rare fish
- Trash item
- Shell
- Bottle message
- Pet food
- Decoration item

---

### Inventory System

The inventory stores collected items.

Example item types:

- Crops
- Fish
- Seeds
- Wood
- Stone
- Decorations
- Pet food

For MVP, the inventory can be simple and text-based first.

---

### Decoration System

Decoration is not required for the first MVP, but it is important for the full game.

Future decorations:

- Fence
- Bench
- Flower pot
- Lantern
- Pet bed
- Table
- Chair
- Bridge
- Mushroom lamp

---

## Suggested Folder Structure

```txt
MeowMeow/
  scenes/
    player/
      Player.tscn
      Player.gd

    world/
      World.tscn
      World.gd

    pets/
      CatPet.tscn
      CatPet.gd

    farming/
      FarmTile.tscn
      FarmTile.gd
      Crop.tscn
      Crop.gd

    fishing/
      FishingSpot.tscn
      FishingSpot.gd

    npc/
      NPC.tscn
      NPC.gd

    ui/
      InventoryUI.tscn
      DialogueUI.tscn

  scripts/
    inventory/
      Inventory.gd

    data/
      ItemDatabase.gd

    save/
      SaveManager.gd

  data/
    items.json
    crops.json
    fish.json
    pets.json

  assets/
    characters/
    pets/
    tiles/
    crops/
    fish/
    ui/
    audio/

  docs/
    game-design.md
    mvp-scope.md
    ai-rules.md
    task-list.md
```

---

## Development Workflow

This project can be built using **Codex** and **Claude Code**.

### Use Claude Code For

Claude Code should help with planning and structure.

Good tasks for Claude Code:

- Create game design documents
- Plan MVP scope
- Break features into small tasks
- Review architecture
- Write AI rules
- Explain system design
- Refactor carefully

Example prompt:

```txt
Help me design the game architecture for Meow Meow ~.

It is a cozy open-world life adventure game made in Godot 4.

Core systems:
- Player movement
- Open-world map
- Pet follower system
- Farming system
- Fishing system
- Inventory system
- Decoration system
- NPC interaction system

Create:
1. docs/game-design.md
2. docs/mvp-scope.md
3. docs/system-breakdown.md
4. docs/ai-rules.md
```

### Use Codex For

Codex should be used for coding small features one by one.

Good tasks for Codex:

- Create player movement
- Create pet follower
- Create farming tile
- Create crop growth
- Create fishing spot
- Create inventory
- Create save/load

Example prompt:

```txt
Create a basic Godot 4 player controller for Meow Meow ~.

Requirements:
- Use GDScript
- Player can move up, down, left, and right
- Camera follows the player
- Keep code simple
- Do not delete existing files
- Only edit files needed for this feature
- Explain what files were changed
```

---

## AI Rules

When using Codex or Claude Code, follow these rules:

```md
# AI Rules for Meow Meow ~

This is a Godot 4 cozy open-world life adventure game.

Do not rewrite the whole project unless asked.

Always make small changes.

Before editing, explain which files will be changed.

Do not delete existing scenes, scripts, or assets.

Keep code simple for a beginner to understand.

Use Godot 4 and GDScript.

For MVP, do not add:
- Redis
- Supabase
- Backend
- Multiplayer
- Login system
- Cloud save

Main MVP systems:
- Player movement
- Open-world test map
- Cat pet follower
- Farming
- Fishing
- Inventory
- Local save
```

---

## Roadmap

### Phase 1: Basic World

- Create Godot project
- Add player movement
- Add camera follow
- Add small test map
- Add collision

### Phase 2: Pet Follower

- Add cat pet scene
- Make pet follow player
- Add simple pet animation
- Prevent pet from blocking player

### Phase 3: Farming

- Add farm soil tile
- Add seed item
- Add crop growth
- Add harvest interaction
- Add crop to inventory

### Phase 4: Fishing

- Add river fishing spot
- Add fishing interaction
- Add fish item
- Add fish to inventory

### Phase 5: Inventory and Save

- Add simple inventory UI
- Store collected items
- Save player position
- Save inventory
- Load save file

### Phase 6: Cozy Expansion

- Add decorations
- Add more pets
- Add NPCs
- Add shops
- Add new map areas
- Add tool upgrades

---

## Getting Started

### 1. Install Godot

Download and install **Godot 4**.

### 2. Clone the Repository

```bash
git clone <your-repo-url>
cd MeowMeow
```

### 3. Open in Godot

Open Godot, then import the project folder.

### 4. Run the Game

Press the **Play** button in Godot.

---

## Current Project Goal

The current goal is to build a simple playable MVP:

> A player can walk around a cute world, have a cat pet follow them, plant and harvest one crop, fish at one river spot, and store items in inventory.

Once this works, the world can slowly become bigger and more detailed.

---

## Project Name

**Meow Meow ~**

A cozy open-world game about pets, farming, fishing, decorating, and peaceful daily life.
