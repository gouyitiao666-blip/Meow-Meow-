extends Node
## Festivals (Phase 7.7).
##
## Backend autoload: loads festival definitions, decides which festival is active
## on a given day, grants one reward per festival day (coins + items), and exposes
## the festival's limited decorations. Emits signals for the frontend banner/FX.

signal festival_started(id: String, name: String)
signal festival_ended(id: String)

const FESTIVALS_PATH := "res://data/festivals.json"

var _defs: Dictionary = {}
var _day_mod := 7
var _active := ""
var _claimed: Dictionary = {}  ## "<festival>:<day>" -> true
var _loaded := false


func _ready() -> void:
	load_festivals()
	var tm := _autoload("TimeManager")
	if tm != null:
		tm.connect("day_changed", Callable(self, "_on_day_changed"))
		_refresh(int(tm.call("get_day")))


func load_festivals(path := FESTIVALS_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("FestivalManager could not open %s" % path)
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("FestivalManager expected a JSON object in %s" % path)
		return false

	_day_mod = max(1, int(parsed.get("schedule_day_mod", 7)))
	_defs.clear()
	var source = parsed.get("festivals", {})
	if typeof(source) == TYPE_DICTIONARY:
		for id in source:
			if typeof(source[id]) == TYPE_DICTIONARY:
				var entry: Dictionary = source[id].duplicate(true)
				entry["id"] = String(id)
				_defs[String(id)] = entry
	_loaded = true
	return true


func festival_for_day(day: int) -> String:
	_ensure_loaded()
	var m: int = int(max(1, day)) % _day_mod
	for id in _defs:
		if int(_defs[id].get("day_match", -1)) == m:
			return String(id)
	return ""


func get_active_festival() -> String:
	return _active


func get_festival(id: String) -> Dictionary:
	_ensure_loaded()
	return _defs.get(id, {}).duplicate(true)


func get_festival_decorations(id: String) -> Array:
	return get_festival(id).get("decorations", [])


## Grants the active festival's reward once per festival day. Returns true if a
## reward was granted (coins to Wallet, items to Inventory).
func claim_reward(day: int) -> bool:
	_ensure_loaded()
	var id := festival_for_day(day)
	if id.is_empty():
		return false
	var key := "%s:%d" % [id, day]
	if _claimed.has(key):
		return false

	var reward: Dictionary = _defs[id].get("reward", {})
	var wallet := _autoload("Wallet")
	if wallet != null:
		wallet.call("add_money", int(reward.get("money", 0)))
	var inventory := _autoload("Inventory")
	if inventory != null:
		for item_id in reward.get("items", {}):
			inventory.call("add_item", item_id, int(reward["items"][item_id]))

	_claimed[key] = true
	return true


func _on_day_changed(day: int) -> void:
	_refresh(day)


func _refresh(day: int) -> void:
	var id := festival_for_day(day)
	if id == _active:
		return
	if _active != "":
		festival_ended.emit(_active)
	_active = id
	if _active != "":
		festival_started.emit(_active, String(_defs[_active].get("name", _active)))


func _ensure_loaded() -> void:
	if not _loaded:
		load_festivals()


func to_dict() -> Dictionary:
	return _claimed.duplicate(true)


func from_dict(data: Dictionary) -> void:
	_claimed.clear()
	for key in data:
		_claimed[String(key)] = true


## Robust autoload lookup that works in-game and in the headless SceneTree test
## (where a node's get_tree() can be null).
func _autoload(node_name: String) -> Node:
	var loop := Engine.get_main_loop()
	if loop is SceneTree and (loop as SceneTree).root != null:
		return (loop as SceneTree).root.get_node_or_null(node_name)
	return null
