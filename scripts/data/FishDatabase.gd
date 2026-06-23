extends Node
## Loads fishing spot definitions and rolls catch rewards.

const FISH_PATH := "res://data/fish.json"
const DEFAULT_SPOT_ID := "river"

var _spots: Dictionary = {}
var _loaded := false
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	load_fish()


func load_fish(path := FISH_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("FishDatabase could not open %s" % path)
		_spots.clear()
		_loaded = false
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("FishDatabase expected a JSON object in %s" % path)
		_spots.clear()
		_loaded = false
		return false

	_spots = _normalize_spots(parsed)
	_loaded = true
	return true


func has_spot(id: String) -> bool:
	_ensure_loaded()
	return _spots.has(id)


func get_spot(id: String = DEFAULT_SPOT_ID) -> Dictionary:
	_ensure_loaded()
	return _spots.get(id, {}).duplicate(true)


func get_all_spots() -> Dictionary:
	_ensure_loaded()
	return _spots.duplicate(true)


func get_wait_time_seconds(id: String = DEFAULT_SPOT_ID) -> float:
	_ensure_loaded()
	var spot := get_spot(id)
	if spot.is_empty():
		return 0.0

	var min_wait := float(spot.get("min_wait_seconds", 0.0))
	var max_wait := float(spot.get("max_wait_seconds", min_wait))
	if max_wait < min_wait:
		max_wait = min_wait

	return _rng.randf_range(min_wait, max_wait)


func roll_reward(id: String = DEFAULT_SPOT_ID) -> Dictionary:
	_ensure_loaded()
	var spot := get_spot(id)
	if spot.is_empty():
		return {}

	var rewards: Array = spot.get("rewards", [])
	var total_weight := 0.0
	for reward in rewards:
		if typeof(reward) == TYPE_DICTIONARY:
			total_weight += maxf(0.0, float(reward.get("weight", 0.0)))

	if total_weight <= 0.0:
		return {}

	var roll := _rng.randf_range(0.0, total_weight)
	var running_weight := 0.0
	for reward in rewards:
		if typeof(reward) != TYPE_DICTIONARY:
			continue

		running_weight += maxf(0.0, float(reward.get("weight", 0.0)))
		if roll <= running_weight:
			return _build_reward_result(reward)

	return _build_reward_result(rewards.back())


func set_roll_seed(seed: int) -> void:
	_rng.seed = seed


func _ensure_loaded() -> void:
	if not _loaded:
		load_fish()


func _normalize_spots(data: Dictionary) -> Dictionary:
	var result := {}
	var source = data.get("spots", data)

	if typeof(source) == TYPE_ARRAY:
		for entry in source:
			if typeof(entry) == TYPE_DICTIONARY and entry.has("id"):
				result[String(entry["id"])] = entry.duplicate(true)
	elif typeof(source) == TYPE_DICTIONARY:
		for id in source:
			if typeof(source[id]) == TYPE_DICTIONARY:
				var entry: Dictionary = source[id].duplicate(true)
				entry["id"] = String(id)
				result[String(id)] = entry

	return result


func _build_reward_result(reward: Dictionary) -> Dictionary:
	var min_amount := int(reward.get("min_amount", reward.get("amount", 1)))
	var max_amount := int(reward.get("max_amount", min_amount))
	if min_amount < 1:
		min_amount = 1
	if max_amount < min_amount:
		max_amount = min_amount

	return {
		"item_id": String(reward.get("item_id", "")),
		"amount": _rng.randi_range(min_amount, max_amount)
	}
