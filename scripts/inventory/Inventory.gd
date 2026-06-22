extends Node
## Global inventory store for MVP item stacks.

signal inventory_changed

var _items: Dictionary = {}


func add_item(id: String, amount: int) -> void:
	if id.is_empty() or amount <= 0:
		return

	_items[id] = get_count(id) + amount
	inventory_changed.emit()


func remove_item(id: String, amount: int) -> bool:
	if id.is_empty() or amount <= 0:
		return false

	var current := get_count(id)
	if current < amount:
		return false

	var next_count := current - amount
	if next_count == 0:
		_items.erase(id)
	else:
		_items[id] = next_count

	inventory_changed.emit()
	return true


func get_count(id: String) -> int:
	return int(_items.get(id, 0))


func has_item(id: String, amount := 1) -> bool:
	return get_count(id) >= amount


func clear() -> void:
	if _items.is_empty():
		return

	_items.clear()
	inventory_changed.emit()


func to_dict() -> Dictionary:
	return _items.duplicate(true)


func from_dict(data: Dictionary) -> void:
	_items.clear()

	for id in data:
		var count := int(data[id])
		if count > 0:
			_items[String(id)] = count

	inventory_changed.emit()


func get_all_items() -> Dictionary:
	return _items.duplicate(true)
