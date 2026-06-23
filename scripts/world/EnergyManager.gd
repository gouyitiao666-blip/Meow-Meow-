extends Node
## Player energy / stamina (Phase 9.3).
##
## Backend autoload: a simple 0..MAX energy pool. Actions (mining/foraging) spend
## it, eating food restores it, and it refills at the start of a new day. The
## frontend energy bar reads it via `energy_changed`. Persists via to_dict/from_dict.

signal energy_changed(energy: int, max_energy: int)

const MAX_ENERGY := 100

var _energy := MAX_ENERGY


func _ready() -> void:
	var tm := _autoload("TimeManager")
	if tm != null:
		tm.connect("day_changed", Callable(self, "_on_day_changed"))


func get_energy() -> int:
	return _energy


func get_max_energy() -> int:
	return MAX_ENERGY


func set_energy(value: int) -> void:
	var next_energy: int = clampi(value, 0, MAX_ENERGY)
	if next_energy == _energy:
		return
	_energy = next_energy
	energy_changed.emit(_energy, MAX_ENERGY)


func has_energy(amount: int) -> bool:
	return _energy >= amount


func spend(amount: int) -> bool:
	if amount <= 0:
		return true
	if _energy < amount:
		return false
	set_energy(_energy - amount)
	return true


func restore(amount: int) -> void:
	if amount > 0:
		set_energy(_energy + amount)


## Eats one `item_id` from the Inventory if it has an `energy` value, restoring it.
func eat(item_id: String) -> bool:
	var inventory := _autoload("Inventory")
	var item_db := _autoload("ItemDatabase")
	if inventory == null or item_db == null:
		return false
	var energy_value := int(item_db.call("get_item", item_id).get("energy", 0))
	if energy_value <= 0:
		return false
	if not bool(inventory.call("remove_item", item_id, 1)):
		return false
	restore(energy_value)
	return true


func _on_day_changed(_day: int) -> void:
	set_energy(MAX_ENERGY)  # a good night's sleep


func to_dict() -> Dictionary:
	return {"energy": _energy}


func from_dict(data: Dictionary) -> void:
	set_energy(int(data.get("energy", MAX_ENERGY)))


func _autoload(node_name: String) -> Node:
	var loop := Engine.get_main_loop()
	if loop is SceneTree and (loop as SceneTree).root != null:
		return (loop as SceneTree).root.get_node_or_null(node_name)
	return null
