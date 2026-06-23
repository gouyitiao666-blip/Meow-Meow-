extends Area2D
class_name FarmTile
## A soil plot. While the player stands on it, pressing "interact":
##   - plants a seed (if the plot is empty and the player has one), or
##   - harvests the crop into the inventory (if it is ready).
## Owns a Crop child for the growing visual. Not a physics body — the player
## walks freely onto the soil; this Area2D only detects them.

@export var crop_id := "carrot"  ## which crop this plot grows (set by World)

enum State { EMPTY, GROWING, READY }

@onready var crop: Crop = $Crop
@onready var prompt: Sprite2D = $Prompt

var _state: State = State.EMPTY
var _player_near := false
var _seed_id := ""
var _harvest_id := ""


func _ready() -> void:
	var data := CropData.get_crop(crop_id)
	_seed_id = data.get("seed_item_id", "")
	_harvest_id = data.get("harvest_item_id", "")
	crop.became_ready.connect(_on_crop_ready)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	crop.visible = false
	prompt.visible = false


func _process(_delta: float) -> void:
	if _player_near and Input.is_action_just_pressed("interact"):
		_interact()
	prompt.visible = _can_interact()


func _interact() -> void:
	match _state:
		State.EMPTY:
			_try_plant()
		State.READY:
			_harvest()
		_:
			pass  # growing — nothing to do yet


func _try_plant() -> void:
	var inventory := _inventory()
	if inventory == null or not bool(inventory.call("remove_item", _seed_id, 1)):
		return  # no seeds
	crop.visible = true
	crop.plant(crop_id)
	_state = State.GROWING
	_play_player_action("res://assets/characters/player_use_hoe.png", 0.7)
	_effect("res://assets/effects/plant_effect.png")


func _on_crop_ready() -> void:
	_state = State.READY


func _harvest() -> void:
	var data := CropData.get_crop(crop_id)
	var yield_range: Dictionary = data.get("harvest_yield", {})
	var lo := int(yield_range.get("min", 1))
	var hi := int(yield_range.get("max", 1))
	var amount := lo + (randi() % maxi(hi - lo + 1, 1))
	var skills := get_node_or_null("/root/SkillManager")
	if skills != null:
		amount += int(skills.call("harvest_bonus"))  # farming level perk
	var inventory := _inventory()
	if inventory != null:
		inventory.call("add_item", _harvest_id, amount)
	var events := get_node_or_null("/root/GameEvents")
	if events != null:
		events.call("report", "harvest", 1)
	crop.visible = false
	_state = State.EMPTY
	_play_player_action("res://assets/characters/player_pickup_item.png", 0.6)
	_effect("res://assets/effects/harvest_effect.png")


func _play_player_action(pose_path: String, seconds: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("play_action"):
		player.call("play_action", pose_path, seconds)


func _effect(path: String) -> void:
	var fx := get_node_or_null("/root/Effects")
	if fx != null:
		fx.call("play", global_position, path)


func _can_interact() -> bool:
	if not _player_near:
		return false
	if _state == State.READY:
		return true
	var inventory := _inventory()
	return _state == State.EMPTY and inventory != null and bool(inventory.call("has_item", _seed_id, 1))


func _inventory() -> Node:
	return get_node_or_null("/root/Inventory")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = false
