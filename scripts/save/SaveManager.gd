extends Node
## Saves and loads the MVP local JSON save file.

signal save_completed(path: String)
signal save_failed(path: String)
signal load_completed(path: String)
signal load_failed(path: String)

const SAVE_VERSION := 1
const SAVE_PATH := "user://save_v1.json"

const DEFAULT_PLAYER_POSITION := {
	"x": 120,
	"y": 80
}
const DEFAULT_PETS := ["cat"]
const DEFAULT_MONEY := 50
const DEFAULT_UNLOCKED_AREAS := ["home", "farm", "river"]

var _inventory_source: Node = null
var _wallet_source: Node = null


func get_save_path() -> String:
	return SAVE_PATH


func set_inventory_source(source: Node) -> void:
	_inventory_source = source


func set_wallet_source(source: Node) -> void:
	_wallet_source = source


func get_default_save_data() -> Dictionary:
	return {
		"player_position": DEFAULT_PLAYER_POSITION.duplicate(true),
		"inventory": {},
		"pets": DEFAULT_PETS.duplicate(true),
		"money": DEFAULT_MONEY,
		"unlocked_areas": DEFAULT_UNLOCKED_AREAS.duplicate(true),
		"decorations": [],
		"tool_levels": {}
	}


func build_save_data(player_position: Vector2 = Vector2.ZERO) -> Dictionary:
	var data := get_default_save_data()
	data["player_position"] = _vector_to_dict(player_position)
	data["inventory"] = _get_inventory_data()
	data["money"] = _get_money_data()
	data["decorations"] = _get_decoration_data()
	data["tool_levels"] = _get_tool_level_data()
	return data


func save_game(path := SAVE_PATH) -> bool:
	return save_data(build_save_data(_get_player_position()), path)


func save_data(data: Dictionary, path := SAVE_PATH) -> bool:
	var normalized := _normalize_save_data(data)
	var json := JSON.stringify(normalized, "\t")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("SaveManager could not write %s" % path)
		save_failed.emit(path)
		return false

	file.store_string(json)
	save_completed.emit(path)
	return true


func load_game(path := SAVE_PATH) -> Dictionary:
	var data := load_data(path)
	if data.is_empty():
		load_failed.emit(path)
		return {}

	_apply_inventory(data)
	_apply_money(data)
	load_completed.emit(path)
	return data


func load_data(path := SAVE_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("SaveManager could not read %s" % path)
		return {}

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("SaveManager expected a JSON object in %s" % path)
		return {}

	return _normalize_save_data(parsed)


func has_save(path := SAVE_PATH) -> bool:
	return FileAccess.file_exists(path)


func _normalize_save_data(data: Dictionary) -> Dictionary:
	var result := get_default_save_data()

	if typeof(data.get("player_position")) == TYPE_DICTIONARY:
		var position: Dictionary = data["player_position"]
		result["player_position"] = {
			"x": int(position.get("x", DEFAULT_PLAYER_POSITION["x"])),
			"y": int(position.get("y", DEFAULT_PLAYER_POSITION["y"]))
		}

	if typeof(data.get("inventory")) == TYPE_DICTIONARY:
		var inventory := {}
		for id in data["inventory"]:
			var count := int(data["inventory"][id])
			if count > 0:
				inventory[String(id)] = count
		result["inventory"] = inventory

	if typeof(data.get("pets")) == TYPE_ARRAY:
		result["pets"] = data["pets"].duplicate(true)

	if data.has("money"):
		result["money"] = max(0, int(data["money"]))

	if typeof(data.get("unlocked_areas")) == TYPE_ARRAY:
		result["unlocked_areas"] = data["unlocked_areas"].duplicate(true)

	if typeof(data.get("decorations")) == TYPE_ARRAY:
		var decorations: Array = []
		for entry in data["decorations"]:
			if typeof(entry) != TYPE_DICTIONARY:
				continue
			var id := String(entry.get("id", ""))
			if id.is_empty() or typeof(entry.get("origin")) != TYPE_DICTIONARY:
				continue
			var origin: Dictionary = entry["origin"]
			decorations.append({
				"id": id,
				"origin": {
					"x": int(origin.get("x", 0)),
					"y": int(origin.get("y", 0))
				}
			})
		result["decorations"] = decorations

	if typeof(data.get("tool_levels")) == TYPE_DICTIONARY:
		var tool_levels := {}
		for id in data["tool_levels"]:
			var level := int(data["tool_levels"][id])
			if level > 0:
				tool_levels[String(id)] = level
		result["tool_levels"] = tool_levels

	return result


func _get_player_position() -> Vector2:
	if not is_inside_tree():
		return Vector2(DEFAULT_PLAYER_POSITION["x"], DEFAULT_PLAYER_POSITION["y"])

	var player := get_tree().get_first_node_in_group("player")
	if player != null and "position" in player:
		return player.position

	return Vector2(DEFAULT_PLAYER_POSITION["x"], DEFAULT_PLAYER_POSITION["y"])


func _get_inventory_data() -> Dictionary:
	var inventory := _get_inventory_node()
	if inventory != null and inventory.has_method("to_dict"):
		return inventory.to_dict()

	return {}


func _apply_inventory(data: Dictionary) -> void:
	var inventory := _get_inventory_node()
	if inventory != null and inventory.has_method("from_dict"):
		inventory.from_dict(data.get("inventory", {}))


func _get_money_data() -> int:
	var wallet := _get_wallet_node()
	if wallet != null and wallet.has_method("to_value"):
		return int(wallet.to_value())

	return DEFAULT_MONEY


func _apply_money(data: Dictionary) -> void:
	var wallet := _get_wallet_node()
	if wallet != null and wallet.has_method("from_value"):
		wallet.from_value(int(data.get("money", DEFAULT_MONEY)))


func _get_decoration_data() -> Array:
	if not is_inside_tree():
		return []

	var world := get_tree().get_first_node_in_group("world")
	if world != null and world.has_method("decorations_to_array"):
		return world.decorations_to_array()

	return []


func _get_tool_level_data() -> Dictionary:
	if not is_inside_tree():
		return {}

	var tool_ui := get_tree().get_first_node_in_group("tool_upgrade_ui")
	if tool_ui != null and tool_ui.has_method("to_dict"):
		return tool_ui.to_dict()

	return {}


func _get_inventory_node() -> Node:
	if _inventory_source != null:
		return _inventory_source
	if not is_inside_tree():
		return null

	var inventory := get_node_or_null("/root/Inventory")
	if inventory != null:
		return inventory
	if get_parent() != null:
		return get_parent().get_node_or_null("Inventory")

	return null


func _get_wallet_node() -> Node:
	if _wallet_source != null:
		return _wallet_source
	if not is_inside_tree():
		return null

	var wallet := get_node_or_null("/root/Wallet")
	if wallet != null:
		return wallet
	if get_parent() != null:
		return get_parent().get_node_or_null("Wallet")

	return null


func _vector_to_dict(value: Vector2) -> Dictionary:
	return {
		"x": int(round(value.x)),
		"y": int(round(value.y))
	}
