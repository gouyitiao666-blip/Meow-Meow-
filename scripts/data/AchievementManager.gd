extends Node
## Achievements (Phase 7.5).
##
## Backend autoload: loads achievement definitions, tracks gameplay progress, and
## emits `achievement_unlocked` so the frontend popup can show it. Gameplay code
## calls `record_event("harvest")`, `record_event("fish")`, etc. Friendship-level
## achievements are recorded automatically from PetFriendship.

signal achievement_unlocked(id: String, name: String)

const ACHIEVEMENTS_PATH := "res://data/achievements.json"

var _defs: Dictionary = {}
var _progress: Dictionary = {}   ## event -> accumulated value
var _unlocked: Dictionary = {}   ## id -> true
var _loaded := false


func _ready() -> void:
	load_achievements()
	var friendship := _autoload("PetFriendship")
	if friendship != null:
		friendship.connect("friendship_changed", Callable(self, "_on_friendship_changed"))


func load_achievements(path := ACHIEVEMENTS_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("AchievementManager could not open %s" % path)
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("AchievementManager expected a JSON object in %s" % path)
		return false

	_defs.clear()
	var source = parsed.get("achievements", parsed)
	if typeof(source) == TYPE_DICTIONARY:
		for id in source:
			if typeof(source[id]) == TYPE_DICTIONARY:
				var entry: Dictionary = source[id].duplicate(true)
				entry["id"] = String(id)
				_defs[String(id)] = entry
	_loaded = true
	return true


## Records progress for an event and unlocks any achievements that reach their
## threshold. `mode` "count" accumulates; "max" keeps the highest value seen.
func record_event(event: String, value := 1) -> void:
	_ensure_loaded()
	if event.is_empty():
		return

	var has_max := false
	for id in _defs:
		if String(_defs[id].get("event", "")) == event and String(_defs[id].get("mode", "count")) == "max":
			has_max = true
	if has_max:
		_progress[event] = max(int(_progress.get(event, 0)), value)
	else:
		_progress[event] = int(_progress.get(event, 0)) + value

	for id in _defs:
		_try_unlock(String(id))


func is_unlocked(id: String) -> bool:
	return _unlocked.has(id)


func get_unlocked() -> Array:
	return _unlocked.keys()


func get_definition(id: String) -> Dictionary:
	_ensure_loaded()
	return _defs.get(id, {}).duplicate(true)


func _try_unlock(id: String) -> void:
	if _unlocked.has(id) or not _defs.has(id):
		return
	var def: Dictionary = _defs[id]
	var event := String(def.get("event", ""))
	var threshold := int(def.get("threshold", 1))
	if int(_progress.get(event, 0)) >= threshold:
		_unlocked[id] = true
		achievement_unlocked.emit(id, String(def.get("name", id)))


func _on_friendship_changed(_pet_id: String, level: int, _points: int) -> void:
	record_event("friendship_level", level)


func _ensure_loaded() -> void:
	if not _loaded:
		load_achievements()


func to_dict() -> Dictionary:
	return {
		"progress": _progress.duplicate(true),
		"unlocked": _unlocked.keys()
	}


func from_dict(data: Dictionary) -> void:
	_progress.clear()
	_unlocked.clear()
	if typeof(data.get("progress")) == TYPE_DICTIONARY:
		for event in data["progress"]:
			_progress[String(event)] = int(data["progress"][event])
	if typeof(data.get("unlocked")) == TYPE_ARRAY:
		for id in data["unlocked"]:
			_unlocked[String(id)] = true


## Robust autoload lookup that works in-game and in the headless SceneTree test
## (where a node's get_tree() can be null).
func _autoload(node_name: String) -> Node:
	var loop := Engine.get_main_loop()
	if loop is SceneTree and (loop as SceneTree).root != null:
		return (loop as SceneTree).root.get_node_or_null(node_name)
	return null
