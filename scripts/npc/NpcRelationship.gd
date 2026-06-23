extends Node
## NPC relationships (Phase 11.3): friendship points/level per villager, raised by
## gifting items. Backend autoload; the dialogue/journal UIs read it. Persists via
## to_dict/from_dict.

signal relationship_changed(npc_id: String, level: int, points: int)

const MAX_LEVEL := 5
const POINTS_PER_LEVEL := 100
const GIFT_POINTS := 20

var _points: Dictionary = {}  ## npc_id -> points


func get_points(npc_id: String) -> int:
	return int(_points.get(npc_id, 0))


func get_level(npc_id: String) -> int:
	return clampi(get_points(npc_id) / POINTS_PER_LEVEL, 0, MAX_LEVEL)


func add_points(npc_id: String, amount: int) -> void:
	if npc_id.is_empty() or amount == 0:
		return
	_points[npc_id] = clampi(get_points(npc_id) + amount, 0, POINTS_PER_LEVEL * MAX_LEVEL)
	relationship_changed.emit(npc_id, get_level(npc_id), get_points(npc_id))


## Gives one `item_id` from the Inventory to an NPC, raising the relationship.
func gift(npc_id: String, item_id: String) -> bool:
	var inventory := _autoload("Inventory")
	if inventory == null or not bool(inventory.call("remove_item", item_id, 1)):
		return false
	add_points(npc_id, GIFT_POINTS)
	return true


func to_dict() -> Dictionary:
	return _points.duplicate(true)


func from_dict(data: Dictionary) -> void:
	_points.clear()
	for npc_id in data:
		_points[String(npc_id)] = max(0, int(data[npc_id]))
	for npc_id in _points:
		relationship_changed.emit(npc_id, get_level(npc_id), get_points(npc_id))


func _autoload(node_name: String) -> Node:
	var loop := Engine.get_main_loop()
	if loop is SceneTree and (loop as SceneTree).root != null:
		return (loop as SceneTree).root.get_node_or_null(node_name)
	return null
