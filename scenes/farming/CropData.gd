class_name CropData
extends RefCounted
## Frontend reader for the backend crop contract (data/crops.json, owned by Codex).
## Loads once and serves crop definitions to the farming scenes.

const CROPS_PATH := "res://data/crops.json"

static var _crops: Dictionary = {}
static var _loaded := false


## Returns the crop definition dict (name, seed_item_id, harvest_item_id,
## grow_time_seconds, stage_assets, harvest_yield) or {} if unknown.
static func get_crop(id: String) -> Dictionary:
	_ensure_loaded()
	return _crops.get(id, {})


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var file := FileAccess.open(CROPS_PATH, FileAccess.READ)
	if file == null:
		push_warning("CropData: cannot open %s" % CROPS_PATH)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has("crops"):
		_crops = parsed["crops"]
	else:
		push_warning("CropData: %s missing a 'crops' object" % CROPS_PATH)
