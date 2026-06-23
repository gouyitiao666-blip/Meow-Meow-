extends Node
## Smoke test for the expanded world map. Run headless as a scene (so the
## project autoloads — Inventory, ItemDatabase, CropData, FishDatabase — load):
##   godot --headless --path . res://build/TestWorld.tscn
## Verifies the gameplay-critical structure: water collision (bridge excluded),
## farm plots, fishing spot, and that the player spawn isn't stuck in a wall.

func _ready() -> void:
	var world: Node = load("res://scenes/world/World.tscn").instantiate()
	add_child(world)
	await get_tree().process_frame
	await get_tree().process_frame

	var ok := true

	# River (5x12 - 5 bridge = 55) + pond (4x4 = 16) = 71 collision tiles.
	var water: Node = world.get_node("WaterBody")
	ok = _check("water collision tiles", water.get_child_count(), 71) and ok

	# Farm plot is 4 x 3 = 12 interactable FarmTiles.
	var farm_tiles := 0
	for c in world.get_children():
		if c.scene_file_path.ends_with("FarmTile.tscn"):
			farm_tiles += 1
	ok = _check("farm tiles", farm_tiles, 12) and ok

	# Two fishing spots now: river + pond (6.5).
	var fishing_spots := get_tree().get_nodes_in_group("fishing_spot")
	ok = _check("fishing spots", fishing_spots.size(), 2) and ok
	var river_spot: Node = null
	for s in fishing_spots:
		if String(s.get("spot_id")) == "river":
			river_spot = s
	if river_spot != null:
		print("PASS: river fishing spot present")
	else:
		push_error("FAIL: river fishing spot missing")
		ok = false

	# Fishing reward path: FishingSpot -> FishDatabase -> Inventory.
	if river_spot != null:
		var inventory = get_node_or_null("/root/Inventory")
		if inventory != null:
			inventory.call("clear")
			river_spot.call("_on_catch_timer_timeout")
			ok = _check("caught small fish", int(inventory.call("get_count", "small_fish")), 1) and ok
			inventory.call("clear")
		else:
			push_error("FAIL: Inventory autoload missing for fishing reward test")
			ok = false

	# Player spawned and is not overlapping a wall at its start position.
	var player: CharacterBody2D = world.get_node("Player")
	if player.move_and_collide(Vector2.ZERO, true) != null:
		push_error("FAIL: player spawn overlaps a collider")
		ok = false
	else:
		print("PASS: player spawn is clear at ", player.position)

	# Save/load wiring: World -> SaveManager -> Inventory + player position.
	var inventory = get_node_or_null("/root/Inventory")
	var save_manager = get_node_or_null("/root/SaveManager")
	if inventory != null and save_manager != null:
		var test_save_path := "user://world_test_save_v1.json"
		inventory.call("from_dict", {"carrot": 7, "small_fish": 1})
		player.position = Vector2(1400, 1500)
		ok = _check("world save call", int(world.call("_save_game", test_save_path)), 1) and ok
		var saved_data: Dictionary = save_manager.call("load_data", test_save_path)
		ok = _check("saved player x", int(saved_data.get("player_position", {}).get("x", 0)), 1400) and ok
		ok = _check("saved carrot count", int(saved_data.get("inventory", {}).get("carrot", 0)), 7) and ok
		inventory.call("clear")
		player.position = Vector2.ZERO
		ok = _check("world load call", int(world.call("_load_game", test_save_path)), 1) and ok
		ok = _check("loaded small fish", int(inventory.call("get_count", "small_fish")), 1) and ok
		ok = _check("loaded player x", int(player.position.x), 1400) and ok
		inventory.call("clear")
	else:
		push_error("FAIL: save/load autoloads missing")
		ok = false

	# Camera limits must cover the whole map AND contain the spawn, or the
	# player ends up clamped off-screen (the "player/cat disappear" bug).
	var cam: Camera2D = player.get_node("Camera2D")
	var in_bounds := player.position.x <= cam.limit_right and player.position.y <= cam.limit_bottom
	ok = _check("camera limit_right", cam.limit_right, 40 * 64) and ok
	ok = _check("camera limit_bottom", cam.limit_bottom, 28 * 64) and ok
	if in_bounds:
		print("PASS: spawn is within camera limits")
	else:
		push_error("FAIL: spawn is outside camera limits (player would be off-screen)")
		ok = false

	# Decoration placement (Phase 6.1): place -> tile occupied -> remove -> free.
	var origin := _find_buildable(world)
	if origin.x >= 0:
		var placed: bool = world.call("place_decoration", "wooden_crate", origin)
		if placed:
			print("PASS: decoration placed at ", origin)
		else:
			push_error("FAIL: decoration could not be placed at a buildable tile")
			ok = false
		var occupied_now: bool = world.call("can_place_footprint", origin, 1, 1)
		if not occupied_now:
			print("PASS: placed tile is now occupied")
		else:
			push_error("FAIL: placed tile still reports buildable")
			ok = false
		var removed: bool = world.call("remove_decoration_at", origin)
		var free_again: bool = world.call("can_place_footprint", origin, 1, 1)
		if removed and free_again:
			print("PASS: decoration removed and tile freed")
		else:
			push_error("FAIL: decoration removal/free failed")
			ok = false
		var persisted: bool = world.call("place_decoration", "wooden_crate", origin)
		ok = _check("decoration replaced for save", int(persisted), 1) and ok
		var decoration_save_path := "user://world_decoration_save_v1.json"
		ok = _check("decoration save call", int(world.call("_save_game", decoration_save_path)), 1) and ok
		var decoration_save: Dictionary = save_manager.call("load_data", decoration_save_path)
		ok = _check("saved decoration count", decoration_save.get("decorations", []).size(), 1) and ok
		world.call("remove_decoration_at", origin)
		ok = _check("decoration load call", int(world.call("_load_game", decoration_save_path)), 1) and ok
		var occupied_after_load: bool = world.call("can_place_footprint", origin, 1, 1)
		if not occupied_after_load:
			print("PASS: decoration restored from save")
		else:
			push_error("FAIL: decoration was not restored from save")
			ok = false
		world.call("remove_decoration_at", origin)
	else:
		push_error("FAIL: no buildable tile found for decoration test")
		ok = false

	# Shop (Phase 6.4): UI present, buy + sell flow through Wallet/ShopDatabase.
	var shop_ui := get_tree().get_first_node_in_group("shop_ui")
	var wallet = get_node_or_null("/root/Wallet")
	if shop_ui != null and wallet != null and inventory != null:
		print("PASS: shop UI instanced")
		wallet.call("set_money", 100)
		inventory.call("clear")
		shop_ui.call("open", "general_store")
		shop_ui.call("buy", "carrot_seed")  # buy_price 5
		ok = _check("shop buy -> seeds", int(inventory.call("get_count", "carrot_seed")), 1) and ok
		ok = _check("shop buy -> money", int(wallet.call("get_money")), 95) and ok
		shop_ui.call("sell", "carrot_seed")  # sell_price 1
		ok = _check("shop sell -> seeds", int(inventory.call("get_count", "carrot_seed")), 0) and ok
		ok = _check("shop sell -> money", int(wallet.call("get_money")), 96) and ok
		shop_ui.call("close")
		inventory.call("clear")
	else:
		push_error("FAIL: shop UI / Wallet not available")
		ok = false

	# Shop trigger present in the world.
	var triggers := 0
	for c in world.get_children():
		if c is ShopTrigger:
			triggers += 1
	ok = _check("shop triggers", triggers, 1) and ok

	# Pets (6.2): cat (from .tscn) + dog + duck + bunny = 4 pet instances.
	var pets := 0
	for c in world.get_children():
		if c.scene_file_path.ends_with("CatPet.tscn"):
			pets += 1
	ok = _check("pet instances", pets, 4) and ok

	# Per-plot crops (6.5): the 12 plots cover all 5 crop types.
	var crop_ids := {}
	for c in world.get_children():
		if c.scene_file_path.ends_with("FarmTile.tscn"):
			crop_ids[String(c.crop_id)] = true
	ok = _check("distinct plot crops", crop_ids.size(), 5) and ok

	# NPCs (6.3): 4 villagers + the dialogue panel that opens for one.
	var npcs := 0
	for c in world.get_children():
		if c is NPC:
			npcs += 1
	ok = _check("npc count", npcs, 4) and ok
	var dialogue_ui := get_tree().get_first_node_in_group("dialogue_ui")
	if dialogue_ui != null:
		dialogue_ui.call("open", "farmer")
		if bool(dialogue_ui.call("is_open")):
			print("PASS: dialogue opens")
		else:
			push_error("FAIL: dialogue did not open")
			ok = false
		dialogue_ui.call("close")
	else:
		push_error("FAIL: dialogue UI missing")
		ok = false

	# Tool upgrades (6.6): spend coins + materials to level a tool up.
	var tool_ui := get_tree().get_first_node_in_group("tool_upgrade_ui")
	if tool_ui != null and wallet != null and inventory != null:
		wallet.call("set_money", 200)
		inventory.call("from_dict", {"wood": 10, "stone": 10})
		var upgraded: bool = tool_ui.call("upgrade", "hoe")  # lv2: 75c, wood5, stone2
		ok = _check("hoe upgraded to lv2", int(tool_ui.call("get_level", "hoe")), 2) and (upgraded and ok)
		ok = _check("upgrade spent money", int(wallet.call("get_money")), 125) and ok
		ok = _check("upgrade spent wood", int(inventory.call("get_count", "wood")), 5) and ok
		ok = _check("upgrade spent stone", int(inventory.call("get_count", "stone")), 8) and ok
		var tool_save_path := "user://world_tool_save_v1.json"
		ok = _check("tool save call", int(world.call("_save_game", tool_save_path)), 1) and ok
		var tool_save: Dictionary = save_manager.call("load_data", tool_save_path)
		ok = _check("saved hoe level", int(tool_save.get("tool_levels", {}).get("hoe", 0)), 2) and ok
		tool_ui.call("from_dict", {"hoe": 1})
		ok = _check("hoe reset before load", int(tool_ui.call("get_level", "hoe")), 1) and ok
		ok = _check("tool load call", int(world.call("_load_game", tool_save_path)), 1) and ok
		ok = _check("hoe restored from save", int(tool_ui.call("get_level", "hoe")), 2) and ok
		inventory.call("clear")
	else:
		push_error("FAIL: tool upgrade UI / Wallet not available")
		ok = false

	print("=== WORLD TEST ", ("PASSED" if ok else "FAILED"), " ===")
	get_tree().quit(0 if ok else 1)


## Scans the map for the first 1x1 buildable (grass, unreserved) tile.
func _find_buildable(world: Node) -> Vector2i:
	for y in range(0, 28):
		for x in range(0, 40):
			if world.call("can_place_footprint", Vector2i(x, y), 1, 1):
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func _check(label: String, got: int, want: int) -> bool:
	if got == want:
		print("PASS: %s = %d" % [label, got])
		return true
	push_error("FAIL: %s = %d (expected %d)" % [label, got, want])
	return false
