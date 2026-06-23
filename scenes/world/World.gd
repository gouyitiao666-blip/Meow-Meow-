extends Node2D
## Cozy open-world map for Meow Meow ~ (Phase 1 expansion).
##
## Region layout (see TASKS.md "Expand World Map"):
##   top-left      → Forest (trees, bushes, mushrooms, rocks)
##   top-right     → River + fishing spot (water with grass edges, a bridge)
##   center        → Open grass + the main dirt path network
##   bottom-left   → Farm (soil plots, wet soil, fences)
##   bottom-center → Home (house, pet bed, fences, flowers)
##   bottom-right  → Empty space for future expansion
##
## Everything is painted from code so the layout stays easy to read and tweak.

const TILE := 64
const MAP_W := 40  ## width in tiles
const MAP_H := 28  ## height in tiles
const WALL_MARGIN := 7.0  ## small invisible-wall buffer added around each solid prop

# TileSet source ids — must match scenes/world/MeowTileSet.tres
const SRC_GRASS := 0
const SRC_PATH := 1
const SRC_WATER := 2
const SRC_WEDGE := 3  ## generic water edge (kept for compatibility; unused here)
const SRC_SOIL := 4
const SRC_WSOIL := 5  ## wet soil
const SRC_BRIDGE := 6
const SRC_WTOP := 7
const SRC_WBOT := 8
const SRC_WLEFT := 9
const SRC_WRIGHT := 10
const SRC_WCTL := 11  ## water corner: top-left
const SRC_WCTR := 12  ## water corner: top-right
const SRC_WCBL := 13  ## water corner: bottom-left
const SRC_WCBR := 14  ## water corner: bottom-right

# --- River rectangle (top-right) ---
const RIVER_X0 := 24
const RIVER_X1 := 28
const RIVER_Y0 := 1
const RIVER_Y1 := 12
const BRIDGE_Y := 8  ## row where the bridge crosses the river

# --- Farm plot (bottom-left) ---
const FARM_X0 := 3
const FARM_X1 := 6
const FARM_Y0 := 19
const FARM_Y1 := 21

const STARTER_SEEDS := 10  ## carrot seeds the player begins with (MVP convenience)
const NATURE_GAP := 2  ## min Chebyshev distance between nature props (clean intervals)

const FARM_TILE_SCENE := preload("res://scenes/farming/FarmTile.tscn")

# Decoration art (assets/nature + assets/buildings + assets/fishing)
const TEX_HOUSE: Texture2D = preload("res://assets/buildings/player_house.png")
const TEX_FENCE: Texture2D = preload("res://assets/buildings/fence.png")
const TEX_PET_BED: Texture2D = preload("res://assets/buildings/pet_bed.png")
const TEX_CRATE: Texture2D = preload("res://assets/buildings/wooden_crate.png")
const TEX_TREE_BIG: Texture2D = preload("res://assets/nature/tree_big.png")
const TEX_TREE_SMALL: Texture2D = preload("res://assets/nature/tree_small.png")
const TEX_ROCK: Texture2D = preload("res://assets/nature/rock.png")
const TEX_FLOWER: Texture2D = preload("res://assets/nature/flower.png")
const TEX_BUSH: Texture2D = preload("res://assets/nature/bush.png")
const TEX_MUSHROOM: Texture2D = preload("res://assets/nature/mushroom.png")
const TEX_LOG: Texture2D = preload("res://assets/nature/log.png")
const FISHING_SPOT_SCENE := preload("res://scenes/fishing/FishingSpot.tscn")
const TEX_SHOP: Texture2D = preload("res://assets/buildings/shop_building.png")
const SHOP_UI_SCENE := preload("res://scenes/ui/ShopUI.tscn")
const SHOP_TRIGGER := preload("res://scenes/shop/ShopTrigger.gd")
const PET_SCENE := preload("res://scenes/pets/CatPet.tscn")
const NPC_SCENE := preload("res://scenes/npc/NPC.tscn")
const DIALOGUE_UI_SCENE := preload("res://scenes/ui/DialogueUI.tscn")
const TEX_WORKBENCH: Texture2D = preload("res://assets/buildings/storage_shed.png")
const TOOL_UPGRADE_UI_SCENE := preload("res://scenes/ui/ToolUpgradeUI.tscn")
const WORKBENCH_TRIGGER := preload("res://scenes/tools/WorkbenchTrigger.gd")

@onready var tilemap: TileMapLayer = $TileMapLayer

const DECORATION_PLACER := preload("res://scenes/world/DecorationPlacer.gd")

var _water_cells: Array[Vector2i] = []  ## solid water tiles (collected while painting)
var _reserved: Dictionary = {}  ## cells nature must avoid (paths, water, structures, spawn)
var _nature_cells: Array[Vector2i] = []  ## placed nature props, for interval spacing
var _placed_decorations: Array = []  ## player-placed decorations (build mode), for removal


func _ready() -> void:
	add_to_group("world")
	_build_ground()
	_build_river()
	_build_pond()
	_build_paths()
	_build_farm()
	_build_decorations()
	_build_fishing_spot()
	_build_shop()
	_build_workbench()
	_build_pets()
	_build_npcs()
	_build_borders()
	_build_water_collision()

	# Spawn the player + cat in the home area (bottom-center).
	$Player.position = _tile_center(20, 23)
	$CatPet.position = _tile_center(19, 23)
	$CatPet.target = $Player

	# Keep the camera bounded to the actual map so it follows the player across
	# the whole world (the .tscn limits were sized for the old 20x12 map, which
	# left the player off-screen after the expansion).
	var cam := $Player.get_node("Camera2D") as Camera2D
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = MAP_W * TILE
	cam.limit_bottom = MAP_H * TILE

	# Load existing progress. New games get starter seeds for the farming loop.
	if not _load_game():
		_grant_starter_seeds()

	# Build mode (Phase 6.1) — press B to place/remove decorations.
	var placer := DECORATION_PLACER.new()
	placer.name = "DecorationPlacer"
	add_child(placer)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_game()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			_save_game()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F9:
			_load_game()
			get_viewport().set_input_as_handled()


func _save_game(path := "") -> bool:
	var save_manager := _save_manager()
	if save_manager == null:
		return false
	if path.is_empty():
		return bool(save_manager.call("save_game"))
	return bool(save_manager.call("save_game", path))


func _load_game(path := "") -> bool:
	var save_manager := _save_manager()
	if save_manager == null:
		return false
	if path.is_empty() and not bool(save_manager.call("has_save")):
		return false

	var data: Dictionary = {}
	if path.is_empty():
		data = save_manager.call("load_game")
	else:
		data = save_manager.call("load_game", path)
	if data.is_empty():
		return false

	_apply_save_data(data)
	return true


func _apply_save_data(data: Dictionary) -> void:
	if typeof(data.get("player_position")) != TYPE_DICTIONARY:
		return

	var position: Dictionary = data["player_position"]
	$Player.position = Vector2(
		float(position.get("x", $Player.position.x)),
		float(position.get("y", $Player.position.y))
	)
	$CatPet.position = $Player.position + Vector2(-TILE, 0)
	_restore_decorations(data.get("decorations", []))
	_restore_tool_levels(data.get("tool_levels", {}))


func _grant_starter_seeds() -> void:
	var inventory := _inventory()
	if inventory == null:
		return
	# A few seeds of every crop so each plot type can be planted right away.
	for crop_id in PLOT_CROPS:
		var seed_id := String(CropData.get_crop(crop_id).get("seed_item_id", ""))
		if seed_id != "":
			inventory.call("add_item", seed_id, STARTER_SEEDS)


func _save_manager() -> Node:
	return get_node_or_null("/root/SaveManager")


func _inventory() -> Node:
	return get_node_or_null("/root/Inventory")


# --- Tile helpers ---------------------------------------------------------

func _paint(x: int, y: int, src: int) -> void:
	tilemap.set_cell(Vector2i(x, y), src, Vector2i.ZERO)


func _tile_center(x: int, y: int) -> Vector2:
	return Vector2(x * TILE + TILE / 2.0, y * TILE + TILE / 2.0)


func _build_ground() -> void:
	# Grass everywhere first; regions paint over it.
	for x in MAP_W:
		for y in MAP_H:
			_paint(x, y, SRC_GRASS)


## Paints a rectangular river with grass-bordered edges/corners (top-right) and
## a bridge crossing it, then records the solid water tiles for collision.
func _build_river() -> void:
	_paint_water_rect(RIVER_X0, RIVER_X1, RIVER_Y0, RIVER_Y1)

	# The bridge spans the whole river width — walkable, so no water collision.
	for x in range(RIVER_X0, RIVER_X1 + 1):
		_paint(x, BRIDGE_Y, SRC_BRIDGE)
		_water_cells.erase(Vector2i(x, BRIDGE_Y))


## A small pond (6.5) in the bottom-right with its own fishing spot.
func _build_pond() -> void:
	_paint_water_rect(33, 36, 22, 25)
	var spot := FISHING_SPOT_SCENE.instantiate()
	spot.spot_id = "pond"
	spot.position = _tile_center(34, 22)  # north edge — reachable from the bank
	add_child(spot)


## Paints a rectangular water body with grass-bordered edges/corners and records
## its tiles for collision. Shared by the river and the pond.
func _paint_water_rect(x0: int, x1: int, y0: int, y1: int) -> void:
	for x in range(x0, x1 + 1):
		for y in range(y0, y1 + 1):
			_paint(x, y, _water_rect_tile(x, y, x0, x1, y0, y1))
			_water_cells.append(Vector2i(x, y))


func _water_rect_tile(x: int, y: int, x0: int, x1: int, y0: int, y1: int) -> int:
	var left := x == x0
	var right := x == x1
	var top := y == y0
	var bottom := y == y1
	if top and left:
		return SRC_WCTL
	if top and right:
		return SRC_WCTR
	if bottom and left:
		return SRC_WCBL
	if bottom and right:
		return SRC_WCBR
	if top:
		return SRC_WTOP
	if bottom:
		return SRC_WBOT
	if left:
		return SRC_WLEFT
	if right:
		return SRC_WRIGHT
	return SRC_WATER


## The main dirt-path network that connects all the areas together.
func _build_paths() -> void:
	# Horizontal trunk across the center.
	for x in range(4, 32):
		_paint(x, 14, SRC_PATH)
	# Forest <-> farm spine (top-left down to the farm).
	for y in range(4, 19):
		_paint(6, y, SRC_PATH)
	# Home spine (trunk down into the home yard).
	for y in range(14, 26):
		_paint(20, y, SRC_PATH)
	# Bridge approach on the left bank (trunk up to the bridge).
	for y in range(BRIDGE_Y, 15):
		_paint(23, y, SRC_PATH)
	# Short lead off the bridge into the fishing area on the right bank.
	_paint(29, BRIDGE_Y, SRC_PATH)
	_paint(30, BRIDGE_Y, SRC_PATH)


## Paints the farm soil plots and drops an interactable FarmTile on each, with a
## decorative strip of wet (watered) soil below.
const PLOT_CROPS := ["carrot", "strawberry", "tomato", "pumpkin", "catnip"]

func _build_farm() -> void:
	var i := 0
	for x in range(FARM_X0, FARM_X1 + 1):
		for y in range(FARM_Y0, FARM_Y1 + 1):
			_paint(x, y, SRC_SOIL)
			var ft := FARM_TILE_SCENE.instantiate()
			ft.crop_id = PLOT_CROPS[i % PLOT_CROPS.size()]  # vary crops across plots
			ft.position = _tile_center(x, y)
			add_child(ft)
			i += 1
	# Wet soil strip just below the plots (visual only — shows wet-soil support).
	for x in range(FARM_X0, FARM_X1 + 1):
		_paint(x, FARM_Y1 + 1, SRC_WSOIL)


## Places all the props. Structures go down first (and reserve their tiles), then
## nature is scattered with collision + clean intervals via `_place_nature`, so
## the map never has overlapping or clumped props on top of paths/water/etc.
func _build_decorations() -> void:
	_reserve_functional_tiles()
	_build_structures()
	_build_tree_border()

	# --- Forest (top-left): a little wood ---
	for t in [Vector2i(2, 3), Vector2i(9, 2), Vector2i(12, 4), Vector2i(3, 9),
			Vector2i(10, 11), Vector2i(6, 2), Vector2i(13, 9), Vector2i(8, 7)]:
		_place_nature(TEX_TREE_BIG, t, 1.4)
	for t in [Vector2i(4, 6), Vector2i(12, 7), Vector2i(2, 12), Vector2i(7, 11)]:
		_place_nature(TEX_TREE_SMALL, t, 1.3)
	for t in [Vector2i(1, 8), Vector2i(12, 13), Vector2i(4, 11)]:
		_place_nature(TEX_ROCK, t, 1.35)
	for t in [Vector2i(8, 4), Vector2i(11, 2), Vector2i(5, 13), Vector2i(10, 6)]:
		_place_nature(TEX_BUSH, t)
	for t in [Vector2i(3, 5), Vector2i(13, 6), Vector2i(9, 9)]:
		_place_nature(TEX_MUSHROOM, t)
	_place_nature(TEX_LOG, Vector2i(6, 8))

	# --- River / fishing (top-right) ---
	for t in [Vector2i(31, 3), Vector2i(37, 6), Vector2i(31, 11)]:
		_place_nature(TEX_ROCK, t, 1.2)
	for t in [Vector2i(34, 4), Vector2i(36, 10), Vector2i(33, 7)]:
		_place_nature(TEX_FLOWER, t)
	_place_nature(TEX_BUSH, Vector2i(35, 12))

	# --- Center open grass: a few well-spaced touches ---
	for t in [Vector2i(15, 6), Vector2i(18, 10), Vector2i(27, 16), Vector2i(13, 17),
			Vector2i(33, 18), Vector2i(31, 21)]:
		_place_nature(TEX_FLOWER, t)
	for t in [Vector2i(24, 16), Vector2i(34, 14), Vector2i(11, 17)]:
		_place_nature(TEX_BUSH, t)

	# --- Home yard (bottom-center): a couple of plants, spaced ---
	for t in [Vector2i(18, 24), Vector2i(24, 24)]:
		_place_nature(TEX_FLOWER, t)
	_place_nature(TEX_BUSH, Vector2i(15, 24))


## Reserves every non-grass tile (paths, water, soil, bridge) plus a 1-tile
## margin around the river and the player/cat spawn, so nature stays clear of them.
func _reserve_functional_tiles() -> void:
	for x in MAP_W:
		for y in MAP_H:
			if tilemap.get_cell_source_id(Vector2i(x, y)) != SRC_GRASS:
				_reserved[Vector2i(x, y)] = true
	for cell in _water_cells:
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				_reserved[Vector2i(cell.x + dx, cell.y + dy)] = true
	# Keep the spawn tiles walkable.
	for c in [Vector2i(20, 23), Vector2i(19, 23), Vector2i(20, 24), Vector2i(19, 24)]:
		_reserved[c] = true


## Solid buildings/fences. Each reserves a footprint so nature won't overlap them.
func _build_structures() -> void:
	# --- Home (bottom-center): a clear, prominent house + pet bed ---
	_place_structure(TEX_HOUSE, Vector2i(16, 21), 1.8, Rect2i(14, 18, 5, 5))
	_place_structure(TEX_PET_BED, Vector2i(23, 23), 1.15, Rect2i(22, 22, 2, 2))
	# Front-yard fence with a gap at the path (x=20).
	for x in [15, 16, 17, 18, 19, 21, 22, 23, 24]:
		_place_structure(TEX_FENCE, Vector2i(x, 26), 1.0, Rect2i(x, 26, 1, 1))

	# --- Farm (bottom-left) fences, leaving the path entrance (6,18) open ---
	for y in range(FARM_Y0, FARM_Y1 + 2):
		_place_structure(TEX_FENCE, Vector2i(FARM_X0 - 1, y), 1.0, Rect2i(FARM_X0 - 1, y, 1, 1))
		_place_structure(TEX_FENCE, Vector2i(FARM_X1 + 1, y), 1.0, Rect2i(FARM_X1 + 1, y, 1, 1))
	for x in range(FARM_X0, FARM_X1):
		_place_structure(TEX_FENCE, Vector2i(x, FARM_Y0 - 1), 1.0, Rect2i(x, FARM_Y0 - 1, 1, 1))

	# A wooden crate set out in the open, away from the farm.
	_place_structure(TEX_CRATE, Vector2i(12, 24), 1.0, Rect2i(12, 24, 1, 1))


func _place_structure(tex: Texture2D, tile: Vector2i, prop_scale: float, footprint: Rect2i) -> void:
	_spawn_prop(tex, tile, true, prop_scale)
	for x in range(footprint.position.x, footprint.position.x + footprint.size.x):
		for y in range(footprint.position.y, footprint.position.y + footprint.size.y):
			_reserved[Vector2i(x, y)] = true


## Frames the map with a ring of trees so the world feels like a cozy clearing in
## the woods. Skips edges that need to stay open (the river and the home yard).
func _build_tree_border() -> void:
	var big := true
	for x in range(0, MAP_W, 3):
		# Top edge — keep clear above the river/bridge.
		if x < 22 or x > 30:
			_place_nature(TEX_TREE_BIG if big else TEX_TREE_SMALL, Vector2i(x, 0), 1.3)
		# Bottom edge — keep clear of the farm and the home yard.
		if (x > 9 and x < 14) or x > 26:
			_place_nature(TEX_TREE_BIG if big else TEX_TREE_SMALL, Vector2i(x, MAP_H - 1), 1.3)
		big = not big
	for y in range(2, MAP_H - 1, 3):
		_place_nature(TEX_TREE_BIG if big else TEX_TREE_SMALL, Vector2i(0, y), 1.3)
		if y < 12 or y > 16:  # right edge (leave a gap by the trunk)
			_place_nature(TEX_TREE_BIG if big else TEX_TREE_SMALL, Vector2i(MAP_W - 1, y), 1.3)
		big = not big


## Places a solid nature prop only if its tile is free and far enough (NATURE_GAP)
## from other nature props — this is what keeps assets at clean intervals.
func _place_nature(tex: Texture2D, tile: Vector2i, prop_scale := 1.0) -> bool:
	if tile.x < 0 or tile.y < 0 or tile.x >= MAP_W or tile.y >= MAP_H:
		return false
	if _reserved.has(tile):
		return false
	for n in _nature_cells:
		if absi(n.x - tile.x) < NATURE_GAP and absi(n.y - tile.y) < NATURE_GAP:
			return false
	_spawn_prop(tex, tile, true, prop_scale)  # every nature prop is now solid
	_nature_cells.append(tile)
	_reserved[tile] = true
	return true


## Interactable fishing spot by the river.
func _build_fishing_spot() -> void:
	var spot := FISHING_SPOT_SCENE.instantiate()
	spot.position = _tile_center(26, 10)
	add_child(spot)


## A general store building + interact trigger, plus the (hidden) shop panel.
func _build_shop() -> void:
	var shop_ui := SHOP_UI_SCENE.instantiate()
	add_child(shop_ui)

	# Store building east of the central path crossroads, on open grass.
	_place_structure(TEX_SHOP, Vector2i(31, 16), 1.4, Rect2i(30, 15, 3, 2))

	var trigger := SHOP_TRIGGER.new()
	trigger.name = "GeneralStoreTrigger"
	trigger.shop_id = "general_store"
	trigger.position = _tile_center(31, 18)
	add_child(trigger)


## Workbench (6.6): a shed building + interact trigger, plus the tool-upgrade panel.
func _build_workbench() -> void:
	var ui := TOOL_UPGRADE_UI_SCENE.instantiate()
	add_child(ui)

	_place_structure(TEX_WORKBENCH, Vector2i(26, 20), 1.2, Rect2i(25, 19, 2, 2))

	var trigger := WORKBENCH_TRIGGER.new()
	trigger.name = "WorkbenchTrigger"
	trigger.position = _tile_center(26, 22)
	add_child(trigger)


## Ambient pets (6.2): the cat follows the player (set up in the .tscn); dog,
## duck and bunny live in their thematic areas as idle animals.
func _build_pets() -> void:
	_spawn_idle_pet("dog", Vector2i(25, 24))   # home yard
	_spawn_idle_pet("duck", Vector2i(22, 11))  # river bank
	_spawn_idle_pet("bunny", Vector2i(8, 22))  # by the farm


func _spawn_idle_pet(pet_id: String, tile: Vector2i) -> void:
	var pet := PET_SCENE.instantiate()
	pet.pet_id = pet_id
	pet.follow = false
	pet.position = _tile_center(tile.x, tile.y)
	add_child(pet)


## NPCs (6.3): villagers you can talk to, plus the shared dialogue panel.
func _build_npcs() -> void:
	var dialogue_ui := DIALOGUE_UI_SCENE.instantiate()
	add_child(dialogue_ui)

	_spawn_npc("farmer", Vector2i(8, 18))       # by the farm
	_spawn_npc("fisher", Vector2i(29, 9))       # right bank of the river
	_spawn_npc("shopkeeper", Vector2i(33, 18))  # next to the shop
	_spawn_npc("villager", Vector2i(18, 24))    # home/village center


func _spawn_npc(npc_id: String, tile: Vector2i) -> void:
	var npc := NPC_SCENE.instantiate()
	npc.npc_id = npc_id
	npc.position = _tile_center(tile.x, tile.y)
	add_child(npc)


func _build_borders() -> void:
	var body := StaticBody2D.new()
	body.name = "WorldBorders"
	add_child(body)

	var w := float(MAP_W * TILE)
	var h := float(MAP_H * TILE)
	var t := 32.0  ## wall thickness

	# top, bottom, left, right
	var rects := [
		Rect2(Vector2(0, -t), Vector2(w, t)),
		Rect2(Vector2(0, h), Vector2(w, t)),
		Rect2(Vector2(-t, 0), Vector2(t, h)),
		Rect2(Vector2(w, 0), Vector2(t, h)),
	]
	for r in rects:
		var shape := RectangleShape2D.new()
		shape.size = r.size
		var col := CollisionShape2D.new()
		col.shape = shape
		col.position = r.position + r.size / 2.0
		body.add_child(col)


## One collision box per water tile (bridge excluded) so the player can't walk
## through the river — only across the bridge.
func _build_water_collision() -> void:
	var body := StaticBody2D.new()
	body.name = "WaterBody"
	add_child(body)
	for cell in _water_cells:
		var shape := RectangleShape2D.new()
		shape.size = Vector2(TILE, TILE)
		var col := CollisionShape2D.new()
		col.shape = shape
		col.position = _tile_center(cell.x, cell.y)
		body.add_child(col)


## Places one prop with its base on the bottom edge of tile `tile`. Solid props
## get a top-down FOOTPRINT wall — collision only over the asset's ground-contact
## area (the bottom slice you'd see from above), not the full canopy/silhouette.
## Returns the created node (StaticBody2D if solid, else Sprite2D).
func _spawn_prop(tex: Texture2D, tile: Vector2i, solid: bool, prop_scale := 1.0) -> Node2D:
	var base := Vector2(tile.x * TILE + TILE / 2.0, float(tile.y * TILE + TILE))
	return _spawn_prop_at_base(tex, base, solid, prop_scale)


## Same as `_spawn_prop` but anchored at an explicit world `base` (bottom-center)
## so multi-tile footprints can be centered. Returns the created node.
func _spawn_prop_at_base(tex: Texture2D, base: Vector2, solid: bool, prop_scale := 1.0) -> Node2D:
	var tw := tex.get_width()
	var th := tex.get_height()

	# Find the actual drawn pixels — used to anchor the sprite AND size the wall.
	var img := tex.get_image()
	var used := Rect2i(0, 0, tw, th)
	if img != null:
		used = img.get_used_rect()

	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.scale = Vector2(prop_scale, prop_scale)
	# Anchor by content bottom so props with transparent padding sit on the ground.
	sprite.offset = Vector2(0, th / 2.0 - float(used.position.y + used.size.y))

	if solid:
		var body := StaticBody2D.new()
		body.position = base
		var foot := _ground_footprint(img, used)  # base-only area, in source pixels
		var box := Vector2(foot.size) * prop_scale + Vector2(WALL_MARGIN, WALL_MARGIN) * 2.0
		var cx := (foot.position.x + foot.size.x / 2.0 - tw / 2.0) * prop_scale
		var shape := RectangleShape2D.new()
		shape.size = box
		var col := CollisionShape2D.new()
		col.shape = shape
		col.position = Vector2(cx, -float(foot.size.y) * prop_scale / 2.0)  # hugs the base
		body.add_child(sprite)
		body.add_child(col)
		add_child(body)
		return body
	else:
		sprite.position = base
		add_child(sprite)
		return sprite


## The asset's ground-contact footprint: the x-extent of opaque pixels within the
## bottom slice of its drawn content (so a tree blocks at its trunk, not canopy).
func _ground_footprint(img: Image, used: Rect2i) -> Rect2i:
	var bottom := used.position.y + used.size.y
	var slice := clampi(int(used.size.y * 0.30), 16, 40)
	var y0 := maxi(used.position.y, bottom - slice)
	if img == null:
		return Rect2i(used.position.x, y0, used.size.x, bottom - y0)
	var minx := used.position.x + used.size.x
	var maxx := used.position.x - 1
	for y in range(y0, bottom):
		for x in range(used.position.x, used.position.x + used.size.x):
			if img.get_pixel(x, y).a > 0.3:
				minx = mini(minx, x)
				maxx = maxi(maxx, x)
	if maxx < minx:
		return Rect2i(used.position.x, y0, used.size.x, bottom - y0)
	return Rect2i(minx, y0, maxx - minx + 1, bottom - y0)


# --- Decoration placement API (Phase 6.1, used by DecorationPlacer) --------

## Tile coordinate under a world-space position (e.g. the mouse).
func tile_from_world(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(floor(world_pos.x / TILE)), int(floor(world_pos.y / TILE)))


## A tile can hold a placed decoration only if it is in-bounds, plain grass, and
## not already reserved (paths, water, props, spawn, or other decorations).
func is_buildable_tile(tile: Vector2i) -> bool:
	if tile.x < 0 or tile.y < 0 or tile.x >= MAP_W or tile.y >= MAP_H:
		return false
	if tilemap.get_cell_source_id(tile) != SRC_GRASS:
		return false
	return not _reserved.has(tile)


## True when every tile of a w×h footprint (top-left = origin) is buildable.
func can_place_footprint(origin: Vector2i, w: int, h: int) -> bool:
	for x in range(origin.x, origin.x + w):
		for y in range(origin.y, origin.y + h):
			if not is_buildable_tile(Vector2i(x, y)):
				return false
	return true


## Places a decoration (by id from DecorationDatabase) with its footprint's
## top-left at `origin`. Reserves the footprint and records it for removal.
func place_decoration(id: String, origin: Vector2i, charge := true) -> bool:
	var db := _decoration_db()
	if db == null:
		return false
	var def: Dictionary = db.call("get_decoration", id)
	if def.is_empty():
		return false

	var fp: Dictionary = def.get("footprint", {})
	var w := int(fp.get("w", 1))
	var h := int(fp.get("h", 1))
	if not can_place_footprint(origin, w, h):
		return false

	var asset_path := String(def.get("asset", ""))
	if asset_path.is_empty() or not ResourceLoader.exists(asset_path):
		return false

	# Charge the decoration's cost (6.4 wallet); refunded on removal.
	var cost := int(def.get("cost", 0))
	var wallet := _wallet()
	if charge and cost > 0:
		if wallet == null or not bool(wallet.call("can_spend", cost)):
			return false
		wallet.call("spend_money", cost)

	var tex: Texture2D = load(asset_path)
	var base := Vector2((origin.x + w / 2.0) * TILE, float((origin.y + h) * TILE))
	var node := _spawn_prop_at_base(tex, base, bool(def.get("solid", true)))

	for x in range(origin.x, origin.x + w):
		for y in range(origin.y, origin.y + h):
			_reserved[Vector2i(x, y)] = true
	_placed_decorations.append({"id": id, "origin": origin, "w": w, "h": h, "node": node, "cost": cost})
	return true


## Removes the player-placed decoration whose footprint covers `tile` (if any).
## Never touches world-built props — only build-mode placements.
func remove_decoration_at(tile: Vector2i) -> bool:
	for i in range(_placed_decorations.size() - 1, -1, -1):
		var d: Dictionary = _placed_decorations[i]
		var o: Vector2i = d["origin"]
		var w := int(d["w"])
		var h := int(d["h"])
		if tile.x >= o.x and tile.x < o.x + w and tile.y >= o.y and tile.y < o.y + h:
			_remove_decoration_index(i, true)
			return true
	return false


func decorations_to_array() -> Array:
	var result: Array = []
	for decoration in _placed_decorations:
		var d: Dictionary = decoration
		var origin: Vector2i = d["origin"]
		result.append({
			"id": String(d.get("id", "")),
			"origin": {
				"x": origin.x,
				"y": origin.y
			}
		})
	return result


func _remove_decoration_index(index: int, refund: bool) -> void:
	var d: Dictionary = _placed_decorations[index]
	var o: Vector2i = d["origin"]
	var w := int(d["w"])
	var h := int(d["h"])
	var node: Node = d["node"]
	if is_instance_valid(node):
		node.queue_free()
	for x in range(o.x, o.x + w):
		for y in range(o.y, o.y + h):
			_reserved.erase(Vector2i(x, y))
	if refund:
		var wallet := _wallet()
		if wallet != null:
			wallet.call("add_money", int(d.get("cost", 0)))
	_placed_decorations.remove_at(index)


func _clear_placed_decorations() -> void:
	for i in range(_placed_decorations.size() - 1, -1, -1):
		_remove_decoration_index(i, false)


func _restore_decorations(data) -> void:
	_clear_placed_decorations()
	if typeof(data) != TYPE_ARRAY:
		return

	for entry in data:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		if typeof(entry.get("origin")) != TYPE_DICTIONARY:
			continue
		var origin: Dictionary = entry["origin"]
		place_decoration(
			String(entry.get("id", "")),
			Vector2i(int(origin.get("x", 0)), int(origin.get("y", 0))),
			false
		)


func _restore_tool_levels(data) -> void:
	if typeof(data) != TYPE_DICTIONARY:
		return
	var tool_ui := get_tree().get_first_node_in_group("tool_upgrade_ui")
	if tool_ui != null and tool_ui.has_method("from_dict"):
		tool_ui.from_dict(data)


func _decoration_db() -> Node:
	return get_node_or_null("/root/DecorationDatabase")


func _wallet() -> Node:
	return get_node_or_null("/root/Wallet")
