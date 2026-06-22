extends Node2D
## Test world for Meow Meow ~ (Phase 1).
## Builds a small grass map with a dirt path and a river (future fishing spot),
## then walls the player in with border colliders. The map is painted from code
## so it stays easy to read and tweak without the Godot editor.

const TILE := 64
const MAP_W := 20  ## width in tiles
const MAP_H := 12  ## height in tiles
const WALL_MARGIN := 7.0  ## small invisible-wall buffer added around each solid prop

# TileSet source ids — must match scenes/world/MeowTileSet.tres
const SRC_GRASS := 0
const SRC_PATH := 1
const SRC_WATER := 2
const SRC_WATER_EDGE := 3

# Decoration art (assets/nature + assets/buildings)
const TEX_HOUSE: Texture2D = preload("res://assets/buildings/player_house.png")
const TEX_FENCE: Texture2D = preload("res://assets/buildings/fence.png")
const TEX_PET_BED: Texture2D = preload("res://assets/buildings/pet_bed.png")
const TEX_TREE_BIG: Texture2D = preload("res://assets/nature/tree_big.png")
const TEX_TREE_SMALL: Texture2D = preload("res://assets/nature/tree_small.png")
const TEX_ROCK: Texture2D = preload("res://assets/nature/rock.png")
const TEX_FLOWER: Texture2D = preload("res://assets/nature/flower.png")

@onready var tilemap: TileMapLayer = $TileMapLayer


func _ready() -> void:
	_build_map()
	_build_borders()
	_build_decorations()
	$CatPet.target = $Player


func _build_map() -> void:
	# Grass everywhere first.
	for x in MAP_W:
		for y in MAP_H:
			tilemap.set_cell(Vector2i(x, y), SRC_GRASS, Vector2i.ZERO)

	# A dirt path down the middle.
	var path_x := MAP_W / 2
	for y in MAP_H:
		tilemap.set_cell(Vector2i(path_x, y), SRC_PATH, Vector2i.ZERO)

	# A river along the right side: an edge column, then open water.
	var river_x := MAP_W - 2
	for y in MAP_H:
		tilemap.set_cell(Vector2i(river_x, y), SRC_WATER_EDGE, Vector2i.ZERO)
		tilemap.set_cell(Vector2i(river_x + 1, y), SRC_WATER, Vector2i.ZERO)


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


## Scatters trees, rocks, a house, etc. across the map. The World node has
## Y-sort on, so a prop placed lower on screen draws in front of the player and
## the player draws in front of props above them — that's why each prop's node
## sits at its BASE (bottom-center) and its sprite is offset upward from there.
func _build_decorations() -> void:
	# Solid props block movement (collision covers each asset's full silhouette).
	_spawn_prop(TEX_HOUSE, Vector2i(1, 2), true)
	_spawn_prop(TEX_FENCE, Vector2i(6, 1), true)
	_spawn_prop(TEX_FENCE, Vector2i(7, 1), true)

	# Trees and rocks are drawn bigger (prop_scale).
	for t in [Vector2i(9, 2), Vector2i(14, 3), Vector2i(2, 8), Vector2i(15, 9), Vector2i(12, 5)]:
		_spawn_prop(TEX_TREE_BIG, t, true, 1.4)
	for t in [Vector2i(5, 4), Vector2i(16, 6)]:
		_spawn_prop(TEX_TREE_SMALL, t, true, 1.3)
	for t in [Vector2i(8, 7), Vector2i(13, 8), Vector2i(3, 6)]:
		_spawn_prop(TEX_ROCK, t, true, 1.35)

	_spawn_prop(TEX_PET_BED, Vector2i(4, 2), true)

	# Flowers are solid obstacles too (every asset blocks the player).
	for t in [Vector2i(6, 3), Vector2i(9, 6), Vector2i(2, 4), Vector2i(14, 7), Vector2i(8, 4), Vector2i(12, 9)]:
		_spawn_prop(TEX_FLOWER, t, true)


## Places one prop with its base on the bottom edge of tile `tile`. Solid props
## get a top-down FOOTPRINT wall — collision only over the asset's ground-contact
## area (the bottom slice you'd see from above), not the full canopy/silhouette.
func _spawn_prop(tex: Texture2D, tile: Vector2i, solid: bool, prop_scale := 1.0) -> void:
	var base := Vector2(tile.x * TILE + TILE / 2.0, float(tile.y * TILE + TILE))
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
	else:
		sprite.position = base
		add_child(sprite)


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
