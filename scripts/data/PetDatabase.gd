extends Node
## Loads static pet definitions for current and future pet followers.

const PETS_PATH := "res://data/pets.json"

var _pets: Dictionary = {}
var _loaded := false


func _ready() -> void:
	load_pets()


func load_pets(path := PETS_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("PetDatabase could not open %s" % path)
		_pets.clear()
		_loaded = false
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("PetDatabase expected a JSON object in %s" % path)
		_pets.clear()
		_loaded = false
		return false

	_pets = _normalize_pets(parsed)
	_loaded = true
	return true


func has_pet(id: String) -> bool:
	_ensure_loaded()
	return _pets.has(id)


func get_pet(id: String) -> Dictionary:
	_ensure_loaded()
	return _pets.get(id, {}).duplicate(true)


func get_all_pets() -> Dictionary:
	_ensure_loaded()
	return _pets.duplicate(true)


func get_default_pet_ids() -> Array[String]:
	_ensure_loaded()
	var defaults: Array[String] = []
	for id in _pets:
		if bool(_pets[id].get("unlocked_by_default", false)):
			defaults.append(String(id))
	defaults.sort()
	return defaults


func _ensure_loaded() -> void:
	if not _loaded:
		load_pets()


func _normalize_pets(data: Dictionary) -> Dictionary:
	var result := {}
	var source = data.get("pets", data)

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
