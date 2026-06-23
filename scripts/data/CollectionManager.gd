extends Node
## Collections / museum (Phase 10.4): sets of items the player can donate. Backend
## autoload; the Collection UI reads it. Donating consumes one item from the
## Inventory and marks it collected. Persists via to_dict/from_dict.

signal collection_changed(item_id: String)
signal set_completed(set_name: String, reward: int)

const COLLECTIONS_PATH := "res://data/collections.json"
const SET_REWARD := 50  ## coins granted when a whole set is completed

var _sets: Dictionary = {}
var _collected: Dictionary = {}  ## item_id -> true
var _rewarded: Dictionary = {}   ## set_name -> true (completion reward claimed)
var _loaded := false


func _ready() -> void:
	load_collections()


func load_collections(path := COLLECTIONS_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("CollectionManager could not open %s" % path)
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	_sets = parsed.get("sets", {}).duplicate(true)
	_loaded = true
	return true


func get_sets() -> Dictionary:
	_ensure_loaded()
	return _sets.duplicate(true)


func is_collected(item_id: String) -> bool:
	return _collected.has(item_id)


func is_collectible(item_id: String) -> bool:
	_ensure_loaded()
	for set_name in _sets:
		if _sets[set_name].has(item_id):
			return true
	return false


## Donates one `item_id` from the Inventory, marking it collected.
func donate(item_id: String, inventory: Node) -> bool:
	_ensure_loaded()
	if not is_collectible(item_id) or _collected.has(item_id):
		return false
	if inventory == null or not bool(inventory.call("remove_item", item_id, 1)):
		return false
	_collected[item_id] = true
	collection_changed.emit(item_id)
	_check_set_completion(item_id)
	return true


## Grants a one-time coin reward when every item in a set is collected.
func _check_set_completion(item_id: String) -> void:
	for set_name in _sets:
		if not _sets[set_name].has(item_id) or _rewarded.has(set_name):
			continue
		var p := set_progress(set_name)
		if p.x == p.y and p.y > 0:
			_rewarded[set_name] = true
			var wallet := _autoload("Wallet")
			if wallet != null:
				wallet.call("add_money", SET_REWARD)
			set_completed.emit(set_name, SET_REWARD)


func _autoload(node_name: String) -> Node:
	var loop := Engine.get_main_loop()
	if loop is SceneTree and (loop as SceneTree).root != null:
		return (loop as SceneTree).root.get_node_or_null(node_name)
	return null


func set_progress(set_name: String) -> Vector2i:
	_ensure_loaded()
	var items: Array = _sets.get(set_name, [])
	var have := 0
	for item_id in items:
		if _collected.has(item_id):
			have += 1
	return Vector2i(have, items.size())


func to_dict() -> Dictionary:
	return {"collected": _collected.keys(), "rewarded": _rewarded.keys()}


func from_dict(data: Dictionary) -> void:
	_collected.clear()
	_rewarded.clear()
	if typeof(data.get("collected")) == TYPE_ARRAY:
		for item_id in data["collected"]:
			_collected[String(item_id)] = true
	if typeof(data.get("rewarded")) == TYPE_ARRAY:
		for set_name in data["rewarded"]:
			_rewarded[String(set_name)] = true


func _ensure_loaded() -> void:
	if not _loaded:
		load_collections()
