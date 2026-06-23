extends Node
## Crafting + cooking recipes (Phase 9.1/9.2).
##
## Backend autoload: loads recipe definitions and performs craft checks. The
## frontend CraftingUI calls `get_by_station`, `can_craft`, and `craft`.

const RECIPES_PATH := "res://data/recipes.json"

var _recipes: Dictionary = {}
var _loaded := false


func _ready() -> void:
	load_recipes()


func load_recipes(path := RECIPES_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("RecipeDatabase could not open %s" % path)
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("RecipeDatabase expected a JSON object in %s" % path)
		return false

	_recipes.clear()
	var source = parsed.get("recipes", parsed)
	if typeof(source) == TYPE_DICTIONARY:
		for id in source:
			if typeof(source[id]) == TYPE_DICTIONARY:
				var entry: Dictionary = source[id].duplicate(true)
				entry["id"] = String(id)
				_recipes[String(id)] = entry
	_loaded = true
	return true


func has_recipe(id: String) -> bool:
	_ensure_loaded()
	return _recipes.has(id)


func get_recipe(id: String) -> Dictionary:
	_ensure_loaded()
	return _recipes.get(id, {}).duplicate(true)


func get_all_recipes() -> Dictionary:
	_ensure_loaded()
	return _recipes.duplicate(true)


func get_by_station(station: String) -> Dictionary:
	_ensure_loaded()
	var result := {}
	for id in _recipes:
		if String(_recipes[id].get("station", "")) == station:
			result[String(id)] = _recipes[id].duplicate(true)
	return result


func can_craft(id: String, inventory: Node) -> bool:
	_ensure_loaded()
	if inventory == null or not _recipes.has(id):
		return false
	for item_id in _recipes[id].get("inputs", {}):
		if not bool(inventory.call("has_item", item_id, int(_recipes[id]["inputs"][item_id]))):
			return false
	return true


## Consumes the recipe's inputs and adds its output. Returns true on success.
func craft(id: String, inventory: Node) -> bool:
	if not can_craft(id, inventory):
		return false
	var recipe: Dictionary = _recipes[id]
	for item_id in recipe.get("inputs", {}):
		inventory.call("remove_item", item_id, int(recipe["inputs"][item_id]))
	inventory.call("add_item", String(recipe.get("output", id)), int(recipe.get("amount", 1)))
	return true


func _ensure_loaded() -> void:
	if not _loaded:
		load_recipes()
