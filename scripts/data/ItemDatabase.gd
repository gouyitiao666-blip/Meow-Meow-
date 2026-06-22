extends Node
## Loads static item definitions for inventory, farming, and fishing.

const ITEMS_PATH := "res://data/items.json"

var _items: Dictionary = {}
var _loaded := false


func _ready() -> void:
	load_items()


func load_items(path := ITEMS_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("ItemDatabase could not open %s" % path)
		_items.clear()
		_loaded = false
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("ItemDatabase expected a JSON object in %s" % path)
		_items.clear()
		_loaded = false
		return false

	_items = _normalize_items(parsed)
	_loaded = true
	return true


func has_item(id: String) -> bool:
	_ensure_loaded()
	return _items.has(id)


func get_item(id: String) -> Dictionary:
	_ensure_loaded()
	return _items.get(id, {}).duplicate(true)


func get_all_items() -> Dictionary:
	_ensure_loaded()
	return _items.duplicate(true)


func _ensure_loaded() -> void:
	if not _loaded:
		load_items()


func _normalize_items(data: Dictionary) -> Dictionary:
	var result := {}
	var source = data.get("items", data)

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
