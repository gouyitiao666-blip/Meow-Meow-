extends Node
## Loads crop definitions and exposes small helpers for planting/harvest logic.

const CROPS_PATH := "res://data/crops.json"

var _crops: Dictionary = {}
var _loaded := false


func _ready() -> void:
	load_crops()


func load_crops(path := CROPS_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("CropDatabase could not open %s" % path)
		_crops.clear()
		_loaded = false
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("CropDatabase expected a JSON object in %s" % path)
		_crops.clear()
		_loaded = false
		return false

	_crops = _normalize_crops(parsed)
	_loaded = true
	return true


func has_crop(id: String) -> bool:
	_ensure_loaded()
	return _crops.has(id)


func get_crop(id: String) -> Dictionary:
	_ensure_loaded()
	return _crops.get(id, {}).duplicate(true)


func get_all_crops() -> Dictionary:
	_ensure_loaded()
	return _crops.duplicate(true)


func get_crop_for_seed(seed_item_id: String) -> Dictionary:
	_ensure_loaded()
	for id in _crops:
		if String(_crops[id].get("seed_item_id", "")) == seed_item_id:
			return _crops[id].duplicate(true)
	return {}


func _ensure_loaded() -> void:
	if not _loaded:
		load_crops()


func _normalize_crops(data: Dictionary) -> Dictionary:
	var result := {}
	var source = data.get("crops", data)

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
