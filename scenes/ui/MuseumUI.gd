extends CanvasLayer
## Museum / collections panel (Phase 10.4). Donate one of an item to mark it
## collected. Reads CollectionManager + Inventory; opened by a UiTrigger.

var _root: Control
var _list: VBoxContainer


func _ready() -> void:
	layer = 12
	add_to_group("museum_ui")
	_build_ui()
	close()
	var inventory := _inventory()
	if inventory != null:
		inventory.connect("inventory_changed", Callable(self, "_on_changed"))


func open() -> void:
	_refresh()
	_root.show()


func close() -> void:
	_root.hide()


func is_open() -> bool:
	return _root.visible


func donate(item_id: String) -> bool:
	var cm := _collections()
	if cm == null:
		return false
	var ok: bool = cm.call("donate", item_id, _inventory())
	if ok:
		var toast := get_tree().get_first_node_in_group("toast_ui")
		if toast != null:
			toast.call("popup", "Donated", item_id.replace("_", " "))
	_refresh()
	return ok


func _on_changed(_a = null) -> void:
	if is_open():
		_refresh()


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.5)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 440)
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	panel.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)
	var title := Label.new()
	title.text = "Museum — Donate to complete collections"
	vbox.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 340)
	vbox.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 4)
	scroll.add_child(_list)
	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(close)
	vbox.add_child(close_btn)


func _refresh() -> void:
	for c in _list.get_children():
		c.queue_free()
	var cm := _collections()
	var inventory := _inventory()
	if cm == null:
		return
	var sets: Dictionary = cm.call("get_sets")
	for set_name in sets:
		var head := Label.new()
		var p: Vector2i = cm.call("set_progress", set_name)
		head.text = "— %s (%d/%d) —" % [set_name, p.x, p.y]
		_list.add_child(head)
		for item_id in sets[set_name]:
			var row := HBoxContainer.new()
			var lbl := Label.new()
			lbl.text = String(item_id).replace("_", " ")
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(lbl)
			if bool(cm.call("is_collected", item_id)):
				var done := Label.new()
				done.text = "✓"
				row.add_child(done)
			else:
				var btn := Button.new()
				btn.text = "Donate"
				btn.disabled = inventory == null or not bool(inventory.call("has_item", item_id, 1))
				btn.pressed.connect(donate.bind(String(item_id)))
				row.add_child(btn)
			_list.add_child(row)


func _collections() -> Node:
	return get_node_or_null("/root/CollectionManager")


func _inventory() -> Node:
	return get_node_or_null("/root/Inventory")
