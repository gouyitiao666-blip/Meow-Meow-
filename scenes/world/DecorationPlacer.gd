extends Node2D
## Build mode (Phase 6.1).
##
## Press **B** to toggle build mode. While active:
##   - **mouse wheel** cycles the selected decoration,
##   - **left click** places it at the tile under the cursor,
##   - **right click** removes a placed decoration there,
##   - **B** again exits.
##
## Decoration data comes from the `DecorationDatabase` autoload; the actual
## placement/collision/validation lives in `World` (the parent), which this node
## calls into. Placement is currently free — wiring `cost` to a money/shop
## system is a follow-up (Phase 6.4).

const TILE := 64  ## must match World.TILE
const PREVIEW_ALPHA := 0.55
const TEX_HL_GREEN: Texture2D = preload("res://assets/ui/tile_highlight_green.png")
const TEX_HL_RED: Texture2D = preload("res://assets/ui/tile_highlight_red.png")

var _world: Node
var _db: Node
var _ids: Array = []
var _index := 0
var _active := false

var _ghost: Sprite2D
var _highlight: Sprite2D
var _label: Label


func _ready() -> void:
	_world = get_parent()
	_db = get_node_or_null("/root/DecorationDatabase")
	if _db != null:
		_ids = _db.call("get_all_decorations").keys()
		_ids.sort()

	_highlight = Sprite2D.new()
	_highlight.z_index = 100
	add_child(_highlight)

	_ghost = Sprite2D.new()
	_ghost.z_index = 101
	_ghost.modulate = Color(1, 1, 1, PREVIEW_ALPHA)
	add_child(_ghost)

	var layer := CanvasLayer.new()
	layer.layer = 11
	add_child(layer)
	_label = Label.new()
	_label.position = Vector2(12, 12)
	layer.add_child(_label)

	_set_active(false)


func _process(_delta: float) -> void:
	if _active:
		_update_preview()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_B:
		_set_active(not _active)
		get_viewport().set_input_as_handled()
		return
	if not _active:
		return
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_cycle(1)
				get_viewport().set_input_as_handled()
			MOUSE_BUTTON_WHEEL_DOWN:
				_cycle(-1)
				get_viewport().set_input_as_handled()
			MOUSE_BUTTON_LEFT:
				_try_place()
				get_viewport().set_input_as_handled()
			MOUSE_BUTTON_RIGHT:
				_try_remove()
				get_viewport().set_input_as_handled()


func _set_active(on: bool) -> void:
	_active = on and not _ids.is_empty()
	_ghost.visible = _active
	_highlight.visible = _active
	_label.visible = _active
	if _active:
		_update_label()
		_update_preview()


func _cycle(dir: int) -> void:
	if _ids.is_empty():
		return
	_index = wrapi(_index + dir, 0, _ids.size())
	_update_label()


func _current_def() -> Dictionary:
	if _db == null or _ids.is_empty():
		return {}
	return _db.call("get_decoration", String(_ids[_index]))


func _footprint(def: Dictionary) -> Vector2i:
	var fp: Dictionary = def.get("footprint", {})
	return Vector2i(int(fp.get("w", 1)), int(fp.get("h", 1)))


func _cursor_origin() -> Vector2i:
	var m := get_global_mouse_position()
	return Vector2i(int(floor(m.x / TILE)), int(floor(m.y / TILE)))


func _update_preview() -> void:
	var def := _current_def()
	if def.is_empty():
		return
	var fp := _footprint(def)
	var origin := _cursor_origin()

	# Ghost sprite, anchored at the footprint's bottom-center like real props.
	var asset_path := String(def.get("asset", ""))
	if asset_path != "" and ResourceLoader.exists(asset_path):
		var tex: Texture2D = load(asset_path)
		_ghost.texture = tex
		var th := tex.get_height()
		var img := tex.get_image()
		var used := Rect2i(0, 0, tex.get_width(), th)
		if img != null:
			used = img.get_used_rect()
		_ghost.offset = Vector2(0, th / 2.0 - float(used.position.y + used.size.y))
		_ghost.position = Vector2((origin.x + fp.x / 2.0) * TILE, float((origin.y + fp.y) * TILE))

	# Highlight covers the whole footprint: green if placeable, red if not.
	var valid: bool = _world.call("can_place_footprint", origin, fp.x, fp.y)
	_highlight.texture = TEX_HL_GREEN if valid else TEX_HL_RED
	var ht := _highlight.texture
	_highlight.scale = Vector2(float(fp.x * TILE) / ht.get_width(), float(fp.y * TILE) / ht.get_height())
	_highlight.position = Vector2((origin.x + fp.x / 2.0) * TILE, (origin.y + fp.y / 2.0) * TILE)


func _try_place() -> void:
	if _ids.is_empty():
		return
	_world.call("place_decoration", String(_ids[_index]), _cursor_origin())


func _try_remove() -> void:
	_world.call("remove_decoration_at", _cursor_origin())


func _update_label() -> void:
	var def := _current_def()
	if def.is_empty():
		_label.text = "BUILD MODE (no decorations)"
		return
	_label.text = "BUILD MODE — %s   |   Wheel: change · LMB: place · RMB: remove · B: exit" % [
		String(def.get("name", "?"))
	]
