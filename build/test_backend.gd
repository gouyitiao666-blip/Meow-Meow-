extends SceneTree


func _initialize() -> void:
	var failures: Array[String] = []

	var inventory = load("res://scripts/inventory/Inventory.gd").new()
	inventory.add_item("carrot", 2)
	inventory.add_item("carrot", 1)
	_expect(inventory.get_count("carrot") == 3, "Inventory stacks added items", failures)
	_expect(inventory.remove_item("carrot", 2), "Inventory removes available items", failures)
	_expect(inventory.get_count("carrot") == 1, "Inventory count updates after removal", failures)
	_expect(not inventory.remove_item("carrot", 2), "Inventory rejects over-removal", failures)

	var saved: Dictionary = inventory.to_dict()
	inventory.clear()
	inventory.from_dict(saved)
	_expect(inventory.get_count("carrot") == 1, "Inventory restores from dictionary", failures)

	var database = load("res://scripts/data/ItemDatabase.gd").new()
	_expect(database.load_items(), "ItemDatabase loads items.json", failures)
	_expect(database.has_item("carrot_seed"), "ItemDatabase has carrot_seed", failures)
	_expect(database.get_item("carrot").get("type", "") == "crop", "ItemDatabase returns carrot definition", failures)
	_expect(database.get_item("small_fish").get("icon", "").contains("small_fish_icon.png"), "ItemDatabase returns fish icon path", failures)

	inventory.free()
	database.free()

	if failures.is_empty():
		print("Backend smoke tests passed")
		quit(0)
	else:
		for failure in failures:
			printerr(failure)
		quit(1)


func _expect(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
