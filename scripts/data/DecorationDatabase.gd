extends Node
## Loads static decoration definitions for future placement/build systems.

const DECORATIONS_PATH := "res://data/decorations.json"

var _decorations: Dictionary = {}
var _loaded := false


func _ready() -> void:
	load_decorations()


func load_decorations(path := DECORATIONS_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("DecorationDatabase could not open %s" % path)
		_decorations.clear()
		_loaded = false
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("DecorationDatabase expected a JSON object in %s" % path)
		_decorations.clear()
		_loaded = false
		return false

	_decorations = _normalize_decorations(parsed)
	_loaded = true
	return true


func has_decoration(id: String) -> bool:
	_ensure_loaded()
	return _decorations.has(id)


func get_decoration(id: String) -> Dictionary:
	_ensure_loaded()
	return _decorations.get(id, {}).duplicate(true)


func get_all_decorations() -> Dictionary:
	_ensure_loaded()
	return _decorations.duplicate(true)


func get_by_category(category: String) -> Dictionary:
	_ensure_loaded()
	var result := {}
	for id in _decorations:
		if String(_decorations[id].get("category", "")) == category:
			result[String(id)] = _decorations[id].duplicate(true)
	return result


func _ensure_loaded() -> void:
	if not _loaded:
		load_decorations()


func _normalize_decorations(data: Dictionary) -> Dictionary:
	var result := {}
	var source = data.get("decorations", data)

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
