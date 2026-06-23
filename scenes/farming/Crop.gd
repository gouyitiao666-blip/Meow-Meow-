extends Node2D
class_name Crop
## A growing crop visual. Reads the crop contract (grow_time_seconds, stage_assets)
## and advances through its growth-stage textures, then flags itself harvestable.

signal became_ready

@onready var sprite: Sprite2D = $Sprite2D

var crop_id := ""
var _stages: Array = []
var _grow_time := 30.0
var _elapsed := 0.0
var is_ready := false


## Plants `id` (e.g. "carrot"). Returns false if the crop is unknown.
func plant(id: String) -> bool:
	var data := CropData.get_crop(id)
	if data.is_empty():
		push_warning("Crop: unknown crop '%s'" % id)
		return false
	crop_id = id
	_stages = data.get("stage_assets", [])
	_grow_time = maxf(float(data.get("grow_time_seconds", 30)), 0.1)
	_elapsed = 0.0
	is_ready = false
	_update_stage()
	return true


func _process(delta: float) -> void:
	if is_ready or _stages.is_empty():
		return
	_elapsed += delta
	if _elapsed >= _grow_time:
		_elapsed = _grow_time
		is_ready = true
		became_ready.emit()
	_update_stage()


## Shows the texture for the current growth progress. The last stage asset is the
## "ready" look; the earlier ones are spread across the grow time.
func _update_stage() -> void:
	var n := _stages.size()
	if n == 0:
		return
	var idx: int
	if is_ready:
		idx = n - 1
	else:
		var grow_n := maxi(n - 1, 1)
		var t := clampf(_elapsed / _grow_time, 0.0, 1.0)
		idx = mini(int(t * grow_n), grow_n - 1)
	sprite.texture = load(_stages[idx])
