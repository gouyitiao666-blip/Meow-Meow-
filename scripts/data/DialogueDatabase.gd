extends Node
## Loads NPC dialogue definitions for future dialogue UI scenes.

const DIALOGUE_PATH := "res://data/dialogue.json"

var _npcs: Dictionary = {}
var _loaded := false


func _ready() -> void:
	load_dialogue()


func load_dialogue(path := DIALOGUE_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("DialogueDatabase could not open %s" % path)
		_npcs.clear()
		_loaded = false
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("DialogueDatabase expected a JSON object in %s" % path)
		_npcs.clear()
		_loaded = false
		return false

	_npcs = _normalize_npcs(parsed)
	_loaded = true
	return true


func has_npc(id: String) -> bool:
	_ensure_loaded()
	return _npcs.has(id)


func get_npc(id: String) -> Dictionary:
	_ensure_loaded()
	return _npcs.get(id, {}).duplicate(true)


func get_all_npcs() -> Dictionary:
	_ensure_loaded()
	return _npcs.duplicate(true)


func get_greeting(id: String) -> String:
	_ensure_loaded()
	return String(_npcs.get(id, {}).get("greeting", ""))


func get_lines(id: String) -> Array:
	_ensure_loaded()
	return _npcs.get(id, {}).get("lines", []).duplicate(true)


func _ensure_loaded() -> void:
	if not _loaded:
		load_dialogue()


func _normalize_npcs(data: Dictionary) -> Dictionary:
	var result := {}
	var source = data.get("npcs", data)

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
