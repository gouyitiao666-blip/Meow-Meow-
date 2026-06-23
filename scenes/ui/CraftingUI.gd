extends CanvasLayer
## Crafting / cooking panel (Phase 9.1/9.2). Lists the station's recipes and
## crafts them through RecipeDatabase (consumes inputs from Inventory → output).
## Pure view over the backend; opened by a CraftStationTrigger.

var _station := ""

var _root: Control
var _title: Label
var _list: VBoxContainer


func _ready() -> void:
	layer = 12
	add_to_group("crafting_ui")
	_build_ui()
	close()

	var inventory := _inventory()
	if inventory != null:
		inventory.connect("inventory_changed", Callable(self, "_on_inventory_changed"))


func open(station: String) -> void:
	_station = station
	_refresh()
	_root.show()


func close() -> void:
	_root.hide()


func is_open() -> bool:
	return _root.visible


func craft(recipe_id: String) -> bool:
	var db := _recipe_db()
	if db == null:
		return false
	var ok: bool = db.call("craft", recipe_id, _inventory())
	if ok:
		var toast := get_tree().get_first_node_in_group("toast_ui")
		if toast != null:
			var r: Dictionary = db.call("get_recipe", recipe_id)
			toast.call("popup", "Crafted", "Made %s" % String(r.get("name", recipe_id)))
	_refresh()
	return ok


func _on_inventory_changed() -> void:
	if is_open():
		_refresh()


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.45)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(380, 360)
	center.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	_title = Label.new()
	_title.text = "Kitchen"
	vbox.add_child(_title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 260)
	vbox.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_list)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(close)
	vbox.add_child(close_btn)


func _refresh() -> void:
	if _list == null:
		return
	_title.text = "%s" % _station.capitalize()

	for child in _list.get_children():
		child.queue_free()

	var db := _recipe_db()
	if db == null:
		return
	var recipes: Dictionary = db.call("get_by_station", _station)
	var ids := recipes.keys()
	ids.sort()
	for id in ids:
		_list.add_child(_make_row(String(id), recipes[id]))


func _make_row(recipe_id: String, recipe: Dictionary) -> Control:
	var inputs: Dictionary = recipe.get("inputs", {})
	var parts := []
	for item_id in inputs:
		parts.append("%s x%d" % [String(item_id).replace("_", " "), int(inputs[item_id])])

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var label := Label.new()
	label.text = "%s  (%s)" % [String(recipe.get("name", recipe_id)), ", ".join(parts)]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	var btn := Button.new()
	btn.text = "Craft"
	var db := _recipe_db()
	btn.disabled = db == null or not bool(db.call("can_craft", recipe_id, _inventory()))
	btn.pressed.connect(craft.bind(recipe_id))
	row.add_child(btn)
	return row


func _recipe_db() -> Node:
	return get_node_or_null("/root/RecipeDatabase")


func _inventory() -> Node:
	return get_node_or_null("/root/Inventory")
