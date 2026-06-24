extends Node
## Smoke test for the expanded world map. Run headless as a scene (so the
## project autoloads — Inventory, ItemDatabase, CropData, FishDatabase — load):
##   godot --headless --path . res://build/TestWorld.tscn
## Verifies the gameplay-critical structure: water collision (bridge excluded),
## farm plots, fishing spot, and that the player spawn isn't stuck in a wall.

func _ready() -> void:
	# Start from a clean slate so a stale save position can't land in new collision.
	DirAccess.remove_absolute("user://save_v1.json")
	var world: Node = load("res://scenes/world/World.tscn").instantiate()
	add_child(world)
	await get_tree().process_frame
	await get_tree().process_frame

	var ok := true

	# River (5x12 - 5 bridge = 55) + pond (4x4 = 16) = 71 collision tiles.
	var water: Node = world.get_node("WaterBody")
	ok = _check("water collision tiles", water.get_child_count(), 93) and ok  # river 55 + pond 16 + ocean 14 + frozen 8 (ocean/pond inset so sand/snow frame them)

	# Farm plot is 4 x 3 = 12 interactable FarmTiles.
	var farm_tiles := 0
	for c in world.get_children():
		if c.scene_file_path.ends_with("FarmTile.tscn"):
			farm_tiles += 1
	ok = _check("farm tiles", farm_tiles, 12) and ok

	# Two fishing spots now: river + pond (6.5).
	var fishing_spots := get_tree().get_nodes_in_group("fishing_spot")
	ok = _check("fishing spots", fishing_spots.size(), 4) and ok  # river, pond, ocean, frozen_pond
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

	# Gameplay smoothness: the player isn't boxed in — it can walk up the home
	# spine and down the new biome-access path without hitting a wall.
	var home := player.position
	player.move_and_collide(Vector2(0, -128))  # up toward the trunk
	var up_moved := home.y - player.position.y
	player.position = home
	player.move_and_collide(Vector2(0, 192))   # down toward the biomes
	var down_moved := player.position.y - home.y
	player.position = home
	# Down = the biome-access path (must be clear); up = just not boxed in
	# (move_and_collide stops on the first graze of the home-yard props).
	if up_moved > 40.0 and down_moved > 150.0:
		print("PASS: not boxed in (up %.0f), biome path clear (down %.0f)" % [up_moved, down_moved])
	else:
		push_error("FAIL: player path blocked (up %.0f, down %.0f)" % [up_moved, down_moved])
		ok = false

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
	ok = _check("camera limit_right", cam.limit_right, 52 * 64) and ok
	ok = _check("camera limit_bottom", cam.limit_bottom, 46 * 64) and ok
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
	ok = _check("pet instances", pets, 8) and ok  # cat,dog,duck,bunny + eagle,penguin,bunny x2

	# Phase 8 gatherables: 3 ore rocks + 1 rare plant.
	ok = _check("gather nodes", get_tree().get_nodes_in_group("gather").size(), 4) and ok

	# Phase 9: crafting UI + energy UI + kitchen station.
	ok = _check("crafting UI present", (1 if get_tree().get_first_node_in_group("crafting_ui") != null else 0), 1) and ok
	var energy_ui := 0
	var kitchen := 0
	for c in world.get_children():
		if c.scene_file_path.ends_with("EnergyUI.tscn"):
			energy_ui += 1
		if c is CraftStationTrigger:
			kitchen += 1
	ok = _check("energy UI present", energy_ui, 1) and ok
	ok = _check("kitchen station present", kitchen, 1) and ok
	var crafting_ui := get_tree().get_first_node_in_group("crafting_ui")
	if crafting_ui != null and inventory != null:
		inventory.call("from_dict", {"stone": 3})
		crafting_ui.call("open", "kitchen")
		var crafted: bool = crafting_ui.call("craft", "ore_shard")
		ok = _check("craft ore_shard via UI", int(inventory.call("get_count", "ore_shard")), 1) and (crafted and ok)
		crafting_ui.call("close")
		inventory.call("clear")

	# Phase 10/11 UIs + community spots present.
	ok = _check("journal UI present", (1 if get_tree().get_first_node_in_group("journal_ui") != null else 0), 1) and ok
	ok = _check("museum UI present", (1 if get_tree().get_first_node_in_group("museum_ui") != null else 0), 1) and ok
	ok = _check("mail UI present", (1 if get_tree().get_first_node_in_group("mail_ui") != null else 0), 1) and ok
	var ui_triggers := 0
	var sleep_triggers := 0
	for c in world.get_children():
		if c is UiTrigger:
			ui_triggers += 1
		if c is SleepTrigger:
			sleep_triggers += 1
	ok = _check("ui triggers (museum+mail)", ui_triggers, 2) and ok
	ok = _check("sleep trigger", sleep_triggers, 1) and ok

	# Phase 12 pause menu + player action poses.
	ok = _check("pause UI present", (1 if get_tree().get_first_node_in_group("pause_ui") != null else 0), 1) and ok

	# Phase 14: settings persistence + controller mappings.
	ok = _check("settings manager present", (1 if get_node_or_null("/root/SettingsManager") != null else 0), 1) and ok
	var has_pad := false
	for e in InputMap.action_get_events("interact"):
		if e is InputEventJoypadButton:
			has_pad = true
	if has_pad:
		print("PASS: controller mapped to interact")
	else:
		push_error("FAIL: no joypad mapping on interact")
		ok = false
	if player.has_method("play_action"):
		print("PASS: player has action poses")
	else:
		push_error("FAIL: player missing play_action")
		ok = false

	# NPC quest turn-in (10.1): completing a giver's quest claims it on talk.
	var qm := get_node_or_null("/root/QuestManager")
	var farmer: Node = null
	for c in world.get_children():
		if c is NPC and String(c.npc_id) == "farmer":
			farmer = c
	if qm != null and farmer != null:
		qm.call("from_dict", {"progress": {}, "claimed": []})
		for i in range(3):
			qm.call("record_event", "harvest", 1)
		farmer.call("_turn_in_quests")
		if bool(qm.call("is_claimed", "first_sprouts")):
			print("PASS: NPC quest turn-in claims completed quest")
		else:
			push_error("FAIL: NPC quest turn-in did not claim")
			ok = false
	else:
		push_error("FAIL: QuestManager/farmer NPC missing")
		ok = false

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

	# Day/night cycle (7.1): phase logic + time saved/restored.
	var tm = get_node_or_null("/root/TimeManager")
	if tm != null:
		tm.call("from_dict", {"minutes": 13 * 60, "day": 1})
		if String(tm.call("get_phase")) == "afternoon":
			print("PASS: time phase at 13:00 is afternoon")
		else:
			push_error("FAIL: wrong phase at 13:00 -> %s" % String(tm.call("get_phase")))
			ok = false
		tm.call("from_dict", {"minutes": 900, "day": 3})
		world.call("_save_game", "user://world_test_save_v1.json")
		tm.call("from_dict", {"minutes": 0, "day": 1})
		world.call("_load_game", "user://world_test_save_v1.json")
		ok = _check("loaded time day", int(tm.call("get_day")), 3) and ok
		ok = _check("loaded time minutes", int(tm.call("get_minutes")), 900) and ok
	else:
		push_error("FAIL: TimeManager autoload missing")
		ok = false

	# Weather system (7.3): autoload state + minimal world overlay hookup.
	var weather = get_node_or_null("/root/WeatherManager")
	if weather != null:
		ok = _check("set rainy weather", int(weather.call("set_weather", "rain")), 1) and ok
		await get_tree().process_frame
		var overlay := world.get_node_or_null("WeatherOverlay")
		if overlay != null:
			print("PASS: weather overlay present")
			ok = _check("rain overlay visible", int(overlay.visible), 1) and ok
		else:
			push_error("FAIL: weather overlay missing")
			ok = false
		world.call("_save_game", "user://world_weather_save_v1.json")
		weather.call("set_weather", "sunny")
		world.call("_load_game", "user://world_weather_save_v1.json")
		ok = _check("loaded weather is rain", int(String(weather.call("get_weather")) == "rain"), 1) and ok
	else:
		push_error("FAIL: WeatherManager autoload missing")
		ok = false

	# Living-world frontend UIs (7.4-7.7) are present in the world.
	var toast_ui := get_tree().get_first_node_in_group("toast_ui")
	if toast_ui != null:
		toast_ui.call("popup", "Test", "hi")  # should not error
		print("PASS: toast UI present")
	else:
		push_error("FAIL: toast UI missing")
		ok = false
	ok = _check("festival UI present", (1 if get_tree().get_first_node_in_group("festival_ui") != null else 0), 1) and ok
	var friendship_ui := 0
	for c in world.get_children():
		if c.scene_file_path.ends_with("FriendshipUI.tscn"):
			friendship_ui += 1
	ok = _check("friendship UI present", friendship_ui, 1) and ok

	# Festival-limited decorations gated by the active festival (7.7).
	var placer := world.get_node_or_null("DecorationPlacer")
	var tm2 = get_node_or_null("/root/TimeManager")
	if placer != null and tm2 != null:
		tm2.call("from_dict", {"minutes": 480, "day": 1})   # no festival on day 1
		placer.call("_refresh_catalog")
		var hidden: bool = not placer._ids.has("festival_banner")
		tm2.call("from_dict", {"minutes": 480, "day": 7})    # pet_festival on day 7
		placer.call("_refresh_catalog")
		var shown: bool = placer._ids.has("festival_banner")
		if hidden and shown:
			print("PASS: festival decoration gated by active festival")
		else:
			push_error("FAIL: festival decoration gating (hidden=%s shown=%s)" % [hidden, shown])
			ok = false
	else:
		push_error("FAIL: DecorationPlacer/TimeManager missing for festival gating")
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
