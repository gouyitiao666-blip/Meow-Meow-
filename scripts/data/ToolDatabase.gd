extends Node
## Loads tool definitions and upgrade requirements.

const TOOLS_PATH := "res://data/tools.json"

var _tools: Dictionary = {}
var _repair: Dictionary = {}
var _loaded := false


func _ready() -> void:
	load_tools()


func load_tools(path := TOOLS_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("ToolDatabase could not open %s" % path)
		_tools.clear()
		_repair.clear()
		_loaded = false
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("ToolDatabase expected a JSON object in %s" % path)
		_tools.clear()
		_repair.clear()
		_loaded = false
		return false

	_tools = _normalize_tools(parsed)
	_repair = parsed.get("repair", {}).duplicate(true)
	_loaded = true
	return true


func has_tool(id: String) -> bool:
	_ensure_loaded()
	return _tools.has(id)


func get_tool(id: String) -> Dictionary:
	_ensure_loaded()
	return _tools.get(id, {}).duplicate(true)


func get_all_tools() -> Dictionary:
	_ensure_loaded()
	return _tools.duplicate(true)


func get_upgrade_cost(id: String, target_level: int) -> Dictionary:
	_ensure_loaded()
	for entry in _tools.get(id, {}).get("upgrade_costs", []):
		if typeof(entry) == TYPE_DICTIONARY and int(entry.get("level", 0)) == target_level:
			return entry.duplicate(true)
	return {}


func get_repair_cost(level: int) -> int:
	_ensure_loaded()
	var safe_level: int = max(1, level)
	return int(_repair.get("base_money", 0)) + int(_repair.get("per_level_money", 0)) * safe_level


func _ensure_loaded() -> void:
	if not _loaded:
		load_tools()


func _normalize_tools(data: Dictionary) -> Dictionary:
	var result := {}
	var source = data.get("tools", data)

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
