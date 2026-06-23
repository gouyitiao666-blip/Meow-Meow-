extends Node
## Loads shop catalogs and performs small buy/sell checks.

const SHOP_PATH := "res://data/shop.json"

var _shops: Dictionary = {}
var _loaded := false


func _ready() -> void:
	load_shops()


func load_shops(path := SHOP_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("ShopDatabase could not open %s" % path)
		_shops.clear()
		_loaded = false
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("ShopDatabase expected a JSON object in %s" % path)
		_shops.clear()
		_loaded = false
		return false

	_shops = _normalize_shops(parsed)
	_loaded = true
	return true


func has_shop(id: String) -> bool:
	_ensure_loaded()
	return _shops.has(id)


func get_shop(id: String) -> Dictionary:
	_ensure_loaded()
	return _shops.get(id, {}).duplicate(true)


func get_all_shops() -> Dictionary:
	_ensure_loaded()
	return _shops.duplicate(true)


func get_shop_item(shop_id: String, item_id: String) -> Dictionary:
	_ensure_loaded()
	var shop := get_shop(shop_id)
	for entry in shop.get("items", []):
		if typeof(entry) == TYPE_DICTIONARY and String(entry.get("item_id", "")) == item_id:
			return entry.duplicate(true)
	return {}


func get_buy_price(shop_id: String, item_id: String) -> int:
	return int(get_shop_item(shop_id, item_id).get("buy_price", -1))


func get_sell_price(shop_id: String, item_id: String) -> int:
	return int(get_shop_item(shop_id, item_id).get("sell_price", -1))


func can_buy(shop_id: String, item_id: String, wallet: Node, amount := 1) -> bool:
	if amount <= 0:
		return false
	var price := get_buy_price(shop_id, item_id)
	return price >= 0 and wallet != null and wallet.has_method("can_spend") and wallet.can_spend(price * amount)


func buy_item(shop_id: String, item_id: String, amount: int, inventory: Node, wallet: Node) -> bool:
	if not can_buy(shop_id, item_id, wallet, amount):
		return false
	if inventory == null or not inventory.has_method("add_item"):
		return false

	var total_price := get_buy_price(shop_id, item_id) * amount
	if not wallet.spend_money(total_price):
		return false

	inventory.add_item(item_id, amount)
	return true


func sell_item(shop_id: String, item_id: String, amount: int, inventory: Node, wallet: Node) -> bool:
	if amount <= 0:
		return false
	var price := get_sell_price(shop_id, item_id)
	if price < 0:
		return false
	if inventory == null or not inventory.has_method("remove_item"):
		return false
	if wallet == null or not wallet.has_method("add_money"):
		return false
	if not inventory.remove_item(item_id, amount):
		return false

	wallet.add_money(price * amount)
	return true


func _ensure_loaded() -> void:
	if not _loaded:
		load_shops()


func _normalize_shops(data: Dictionary) -> Dictionary:
	var result := {}
	var source = data.get("shops", data)

	if typeof(source) == TYPE_ARRAY:
		for entry in source:
			if typeof(entry) == TYPE_DICTIONARY and entry.has("id"):
				result[String(entry["id"])] = entry.duplicate(true)
	elif typeof(source) == TYPE_DICTIONARY:
		for id in source:
			if typeof(source[id]) == TYPE_DICTIONARY:
				var entry: Dictionary = source[id].duplicate(true)
				entry["id"] = String(id)
				result[String(id)] = entry

	return result
