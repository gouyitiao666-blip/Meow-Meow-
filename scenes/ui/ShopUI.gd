extends CanvasLayer
## Shop panel (Phase 6.4) — buy/sell items for coins.
##
## Pure view + thin controller over the backend autoloads:
##   - `ShopDatabase` owns the catalog + buy/sell rules,
##   - `Wallet` owns the money, `Inventory` owns the items.
## This panel just displays them and calls `ShopDatabase.buy_item/sell_item`.
## Opened by a `ShopTrigger` in the world; closed with the Close button.

var _shop_id := ""

var _root: Control
var _title: Label
var _coins: Label
var _list: VBoxContainer


func _ready() -> void:
	layer = 12
	add_to_group("shop_ui")
	_build_ui()
	close()

	var wallet := _wallet()
	if wallet != null:
		wallet.connect("money_changed", Callable(self, "_on_state_changed"))
	var inventory := _inventory()
	if inventory != null:
		inventory.connect("inventory_changed", Callable(self, "_on_state_changed"))


func open(shop_id: String) -> void:
	_shop_id = shop_id
	_refresh()
	_root.show()


func close() -> void:
	_root.hide()


func is_open() -> bool:
	return _root.visible


## Buy/sell one unit — also called directly by the buy/sell buttons.
func buy(item_id: String) -> bool:
	var shop_db := _shop_db()
	if shop_db == null:
		return false
	var ok: bool = shop_db.call("buy_item", _shop_id, item_id, 1, _inventory(), _wallet())
	_refresh()
	return ok


func sell(item_id: String) -> bool:
	var shop_db := _shop_db()
	if shop_db == null:
		return false
	var ok: bool = shop_db.call("sell_item", _shop_id, item_id, 1, _inventory(), _wallet())
	_refresh()
	return ok


func _on_state_changed(_arg = null) -> void:
	if is_open():
		_refresh()


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	# Dim background that also blocks clicks behind the panel.
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.45)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(360, 380)
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
	_title = Label.new()
	_title.text = "Shop"
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_title)
	_coins = Label.new()
	_coins.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
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

	var shop_db := _shop_db()
	var shop: Dictionary = shop_db.call("get_shop", _shop_id) if shop_db != null else {}
	_title.text = String(shop.get("name", "Shop"))

	for child in _list.get_children():
		child.queue_free()

	for entry in shop.get("items", []):
		if typeof(entry) == TYPE_DICTIONARY:
			_list.add_child(_make_row(entry))


func _make_row(entry: Dictionary) -> Control:
	var item_id := String(entry.get("item_id", ""))
	var buy_price := int(entry.get("buy_price", -1))
	var sell_price := int(entry.get("sell_price", -1))

	var wallet := _wallet()
	var inventory := _inventory()
	var owned := int(inventory.call("get_count", item_id)) if inventory != null else 0
	var display_name := item_id
	var item_db := _item_database()
	if item_db != null:
		var def: Dictionary = item_db.call("get_item", item_id)
		display_name = String(def.get("name", item_id))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var name_label := Label.new()
	name_label.text = "%s (x%d)" % [display_name, owned]
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)

	var buy_btn := Button.new()
	buy_btn.text = "Buy %d" % buy_price
	buy_btn.disabled = buy_price < 0 or wallet == null or not bool(wallet.call("can_spend", buy_price))
	buy_btn.pressed.connect(buy.bind(item_id))
	row.add_child(buy_btn)

	var sell_btn := Button.new()
	sell_btn.text = "Sell %d" % sell_price
	sell_btn.disabled = sell_price < 0 or owned <= 0
	sell_btn.pressed.connect(sell.bind(item_id))
	row.add_child(sell_btn)

	return row


func _shop_db() -> Node:
	return get_node_or_null("/root/ShopDatabase")


func _wallet() -> Node:
	return get_node_or_null("/root/Wallet")


func _inventory() -> Node:
	return get_node_or_null("/root/Inventory")


func _item_database() -> Node:
	return get_node_or_null("/root/ItemDatabase")
