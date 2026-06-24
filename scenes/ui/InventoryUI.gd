extends CanvasLayer
## Player-facing inventory panel (Phase 5.3).
##
## Reads from the backend autoloads only:
##   - `Inventory` for the item counts (and the `inventory_changed` signal)
##   - `ItemDatabase` for each item's display name + icon
## It owns no item data of its own — it just mirrors backend state.
##
## Toggle with the "inventory" input action (I / Esc). Hidden at start.

const COLUMNS := 4
const SLOT_SIZE := Vector2(64, 64)

var _panel: PanelContainer
var _grid: GridContainer


func _ready() -> void:
	layer = 10
	_build_ui()
	hide_panel()
	# Keep the view in sync with the backend store.
	var inventory := _inventory()
	if inventory != null:
		inventory.connect("inventory_changed", Callable(self, "_refresh"))
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	if _panel.visible:
		hide_panel()
	else:
		show_panel()


func show_panel() -> void:
	_refresh()
	_panel.show()


func hide_panel() -> void:
	_panel.hide()


func _build_ui() -> void:
	# Centered wrapper so the panel floats in the middle of the screen.
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	_panel = PanelContainer.new()
	# Cozy decorative frame; big content margin keeps the grid inside the cream
	# centre (clear of the wooden frame + corner flowers).
	UiSkin.apply_panel(_panel, "res://assets/ui/inventory_panel.png", 54.0, 46.0)
	_panel.custom_minimum_size = Vector2(360, 300)
	center.add_child(_panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Inventory"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", 8)
	_grid.add_theme_constant_override("v_separation", 8)
	vbox.add_child(_grid)


func _refresh() -> void:
	if _grid == null:
		return

	for child in _grid.get_children():
		child.queue_free()

	var inventory := _inventory()
	var items: Dictionary = {}
	if inventory != null:
		items = inventory.call("get_all_items")
	if items.is_empty():
		var empty := Label.new()
		empty.text = "(empty)"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_grid.add_child(empty)
		return

	var ids := items.keys()
	ids.sort()
	for id in ids:
		_grid.add_child(_make_slot(String(id), int(items[id])))


func _make_slot(id: String, count: int) -> Control:
	var database := _item_database()
	var def: Dictionary = {}
	if database != null:
		def = database.call("get_item", id)
	var display_name := String(def.get("name", id))

	var slot := PanelContainer.new()
	slot.custom_minimum_size = SLOT_SIZE
	slot.tooltip_text = "%s x%d" % [display_name, count]
	UiSkin.apply_slot(slot, "res://assets/ui/inventory_slot.png")

	# Icon (falls back to nothing if the asset is missing).
	var icon := TextureRect.new()
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon_path := String(def.get("icon", ""))
	if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
		icon.texture = load(icon_path)
	slot.add_child(icon)

	# Count badge in the bottom-right corner.
	var count_label := Label.new()
	count_label.text = "x%d" % count
	count_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	count_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	count_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(count_label)

	return slot


func _inventory() -> Node:
	return get_node_or_null("/root/Inventory")


func _item_database() -> Node:
	return get_node_or_null("/root/ItemDatabase")
