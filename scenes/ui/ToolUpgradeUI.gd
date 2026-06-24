extends CanvasLayer
## Tool upgrade workbench panel (Phase 6.6). Spend coins + materials to level up
## tools, using costs from the ToolDatabase autoload, money from Wallet, and
## materials from Inventory. Tool levels are held here at runtime (persisting them
## to the save file is a follow-up).

var _levels: Dictionary = {}  ## tool_id -> current level

var _root: Control
var _coins: Label
var _list: VBoxContainer


func _ready() -> void:
	layer = 12
	add_to_group("tool_upgrade_ui")
	_init_levels()
	_build_ui()
	close()

	var wallet := _wallet()
	if wallet != null:
		wallet.connect("money_changed", Callable(self, "_on_state_changed"))
	var inventory := _inventory()
	if inventory != null:
		inventory.connect("inventory_changed", Callable(self, "_on_state_changed"))


func open() -> void:
	_refresh()
	_root.show()


func close() -> void:
	_root.hide()


func is_open() -> bool:
	return _root.visible


func get_level(tool_id: String) -> int:
	return int(_levels.get(tool_id, 1))


func to_dict() -> Dictionary:
	return _levels.duplicate(true)


func from_dict(data: Dictionary) -> void:
	_init_levels()
	for tool_id in data:
		_levels[String(tool_id)] = max(1, int(data[tool_id]))
	_refresh()


## Attempt to upgrade one level — also called by the row's Upgrade button.
func upgrade(tool_id: String) -> bool:
	var db := _tool_db()
	if db == null:
		return false
	var level := get_level(tool_id)
	var tool: Dictionary = db.call("get_tool", tool_id)
	if level >= int(tool.get("max_level", 1)):
		return false

	var cost: Dictionary = db.call("get_upgrade_cost", tool_id, level + 1)
	if cost.is_empty():
		return false
	var money := int(cost.get("money", 0))
	var items: Dictionary = cost.get("items", {})

	var wallet := _wallet()
	var inventory := _inventory()
	if wallet == null or inventory == null or not bool(wallet.call("can_spend", money)):
		return false
	for item_id in items:
		if not bool(inventory.call("has_item", item_id, int(items[item_id]))):
			return false

	wallet.call("spend_money", money)
	for item_id in items:
		inventory.call("remove_item", item_id, int(items[item_id]))
	_levels[tool_id] = level + 1
	_refresh()
	return true


func _init_levels() -> void:
	var db := _tool_db()
	if db == null:
		return
	for tool_id in db.call("get_all_tools").keys():
		_levels[tool_id] = 1


func _on_state_changed(_arg = null) -> void:
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
	panel.custom_minimum_size = Vector2(460, 410)
	# Uses the clean global parchment theme (a tidy list card).
	center.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)
	var title := Label.new()
	title.text = "Workbench — Tool Upgrades"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	_coins = Label.new()
	header.add_child(_coins)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 280)
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
	var wallet := _wallet()
	_coins.text = "Coins: %d" % (int(wallet.call("get_money")) if wallet != null else 0)

	for child in _list.get_children():
		child.queue_free()

	var db := _tool_db()
	if db == null:
		return
	var tools: Dictionary = db.call("get_all_tools")
	var ids := tools.keys()
	ids.sort()
	for tool_id in ids:
		_list.add_child(_make_row(String(tool_id), tools[tool_id]))


func _make_row(tool_id: String, tool: Dictionary) -> Control:
	var level := get_level(tool_id)
	var max_level := int(tool.get("max_level", 1))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	# Tool icon in a slot, then the name + level.
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(40, 40)
	slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UiSkin.apply_slot(slot, "res://assets/ui/tool_slot.png")
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(30, 30)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var icon_path := String(tool.get("icon", ""))
	if icon_path != "" and ResourceLoader.exists(icon_path):
		icon.texture = load(icon_path)
	slot.add_child(icon)
	row.add_child(slot)

	var name_label := Label.new()
	name_label.text = "%s  Lv %d/%d" % [String(tool.get("name", tool_id)), level, max_level]
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(name_label)

	var btn := Button.new()
	if level >= max_level:
		btn.text = "Max"
		btn.disabled = true
	else:
		var db := _tool_db()
		var cost: Dictionary = db.call("get_upgrade_cost", tool_id, level + 1)
		btn.text = "Upgrade (%s)" % _cost_text(cost)
		btn.disabled = not _can_afford(cost)
		btn.pressed.connect(upgrade.bind(tool_id))
	row.add_child(btn)

	return row


func _cost_text(cost: Dictionary) -> String:
	var parts := ["%dc" % int(cost.get("money", 0))]
	for item_id in cost.get("items", {}):
		parts.append("%s x%d" % [item_id, int(cost["items"][item_id])])
	return ", ".join(parts)


func _can_afford(cost: Dictionary) -> bool:
	var wallet := _wallet()
	var inventory := _inventory()
	if wallet == null or inventory == null or not bool(wallet.call("can_spend", int(cost.get("money", 0)))):
		return false
	for item_id in cost.get("items", {}):
		if not bool(inventory.call("has_item", item_id, int(cost["items"][item_id]))):
			return false
	return true


func _tool_db() -> Node:
	return get_node_or_null("/root/ToolDatabase")


func _wallet() -> Node:
	return get_node_or_null("/root/Wallet")


func _inventory() -> Node:
	return get_node_or_null("/root/Inventory")
