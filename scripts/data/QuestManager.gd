extends Node
## Quests (Phase 10.1): small objectives tracked from gameplay events. A quest
## completes when its event count reaches the target; the player claims the
## reward once. Backend autoload; the Quest Log UI reads it via signals.

signal quest_progress(id: String, progress: int, target: int)
signal quest_completed(id: String, name: String)
signal quest_claimed(id: String)

const QUESTS_PATH := "res://data/quests.json"

var _defs: Dictionary = {}
var _progress: Dictionary = {}   ## event -> count
var _claimed: Dictionary = {}    ## id -> true
var _loaded := false


func _ready() -> void:
	load_quests()


func load_quests(path := QUESTS_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("QuestManager could not open %s" % path)
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	_defs.clear()
	var source = parsed.get("quests", parsed)
	if typeof(source) == TYPE_DICTIONARY:
		for id in source:
			if typeof(source[id]) == TYPE_DICTIONARY:
				var entry: Dictionary = source[id].duplicate(true)
				entry["id"] = String(id)
				_defs[String(id)] = entry
	_loaded = true
	return true


func record_event(event: String, amount := 1) -> void:
	_ensure_loaded()
	_progress[event] = int(_progress.get(event, 0)) + amount
	for id in _defs:
		if String(_defs[id].get("event", "")) == event and is_complete(String(id)) and not _claimed.has(id):
			quest_completed.emit(String(id), String(_defs[id].get("name", id)))
	# Always emit progress for active quests on this event.
	for id in _defs:
		if String(_defs[id].get("event", "")) == event:
			quest_progress.emit(String(id), get_progress(String(id)), int(_defs[id].get("target", 1)))


func get_all_quests() -> Dictionary:
	_ensure_loaded()
	return _defs.duplicate(true)


func get_progress(id: String) -> int:
	_ensure_loaded()
	if not _defs.has(id):
		return 0
	return min(int(_progress.get(String(_defs[id].get("event", "")), 0)), int(_defs[id].get("target", 1)))


func is_complete(id: String) -> bool:
	_ensure_loaded()
	return _defs.has(id) and int(_progress.get(String(_defs[id].get("event", "")), 0)) >= int(_defs[id].get("target", 1))


func is_claimed(id: String) -> bool:
	return _claimed.has(id)


## Grants the reward (coins + items) if the quest is complete and unclaimed.
func claim(id: String) -> bool:
	_ensure_loaded()
	if not is_complete(id) or _claimed.has(id):
		return false
	var reward: Dictionary = _defs[id].get("reward", {})
	var wallet := _autoload("Wallet")
	if wallet != null:
		wallet.call("add_money", int(reward.get("money", 0)))
	var inventory := _autoload("Inventory")
	if inventory != null:
		for item_id in reward.get("items", {}):
			inventory.call("add_item", item_id, int(reward["items"][item_id]))
	_claimed[id] = true
	quest_claimed.emit(id)
	return true


func to_dict() -> Dictionary:
	return {"progress": _progress.duplicate(true), "claimed": _claimed.keys()}


func from_dict(data: Dictionary) -> void:
	_progress.clear()
	_claimed.clear()
	if typeof(data.get("progress")) == TYPE_DICTIONARY:
		for event in data["progress"]:
			_progress[String(event)] = int(data["progress"][event])
	if typeof(data.get("claimed")) == TYPE_ARRAY:
		for id in data["claimed"]:
			_claimed[String(id)] = true


func _ensure_loaded() -> void:
	if not _loaded:
		load_quests()


func _autoload(node_name: String) -> Node:
	var loop := Engine.get_main_loop()
	if loop is SceneTree and (loop as SceneTree).root != null:
		return (loop as SceneTree).root.get_node_or_null(node_name)
	return null
