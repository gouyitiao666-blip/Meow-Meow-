extends Node
## Pet friendship store (Phase 7.4).
##
## Backend autoload: owns each pet's friendship points/level, feeding rules
## (likes/dislikes from PetDatabase favorites), and a passive-ability gate.
## Frontend (friendship UI, pet emotes, feed interaction) reads it via signals.

signal friendship_changed(pet_id: String, level: int, points: int)
signal pet_fed(pet_id: String, item_id: String, liked: bool)

const MAX_LEVEL := 5
const POINTS_PER_LEVEL := 100
const FAVORITE_POINTS := 25
const NORMAL_POINTS := 10
const DISLIKE_POINTS := -5
const ABILITY_LEVEL := 3  ## passive ability unlocks at this level

const DISLIKES := ["stone", "wood"]  ## not food — feeding these annoys the pet

var _points: Dictionary = {}  ## pet_id -> int points


func get_points(pet_id: String) -> int:
	return int(_points.get(pet_id, 0))


func get_level(pet_id: String) -> int:
	return clampi(get_points(pet_id) / POINTS_PER_LEVEL, 0, MAX_LEVEL)


func add_points(pet_id: String, amount: int) -> void:
	if pet_id.is_empty() or amount == 0:
		return
	var before := get_level(pet_id)
	_points[pet_id] = max(0, get_points(pet_id) + amount)
	friendship_changed.emit(pet_id, get_level(pet_id), get_points(pet_id))
	var after := get_level(pet_id)
	if after != before:
		# Level changes are interesting for achievements / UI.
		pass


func get_favorite(pet_id: String) -> String:
	var db := _autoload("PetDatabase")
	if db != null:
		return String(db.call("get_pet", pet_id).get("favorite_item_id", ""))
	return ""


func likes(pet_id: String, item_id: String) -> bool:
	return item_id != "" and item_id == get_favorite(pet_id)


func dislikes(_pet_id: String, item_id: String) -> bool:
	return DISLIKES.has(item_id)


## Consumes one `item_id` from the Inventory and awards friendship accordingly.
## Returns true if the item was available and consumed.
func feed(pet_id: String, item_id: String) -> bool:
	var inventory := _autoload("Inventory")
	if inventory == null or not bool(inventory.call("remove_item", item_id, 1)):
		return false

	var liked := likes(pet_id, item_id)
	var points := FAVORITE_POINTS if liked else (DISLIKE_POINTS if dislikes(pet_id, item_id) else NORMAL_POINTS)
	add_points(pet_id, points)
	pet_fed.emit(pet_id, item_id, liked)
	return true


func has_passive_ability(pet_id: String) -> bool:
	return get_level(pet_id) >= ABILITY_LEVEL


func to_dict() -> Dictionary:
	return _points.duplicate(true)


func from_dict(data: Dictionary) -> void:
	_points.clear()
	for pet_id in data:
		var pts := int(data[pet_id])
		if pts > 0:
			_points[String(pet_id)] = pts
	for pet_id in _points:
		friendship_changed.emit(pet_id, get_level(pet_id), get_points(pet_id))


## Robust autoload lookup that works in-game and in the headless SceneTree test
## (where a node's get_tree() can be null).
func _autoload(node_name: String) -> Node:
	var loop := Engine.get_main_loop()
	if loop is SceneTree and (loop as SceneTree).root != null:
		return (loop as SceneTree).root.get_node_or_null(node_name)
	return null
