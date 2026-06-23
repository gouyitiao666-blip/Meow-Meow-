extends Area2D
class_name FishingSpot
## River fishing interaction. The frontend owns the timing/interaction feel,
## while FishDatabase owns reward data and roll logic.

signal fishing_started(wait_seconds: float)
signal fish_caught(item_id: String, amount: int)

@export var spot_id := "river"  ## which fish.json spot this rolls from
const FALLBACK_WAIT_SECONDS := 2.0

@onready var prompt: Sprite2D = $Prompt
@onready var catch_timer: Timer = $CatchTimer

var _player_near := false
var _is_fishing := false


func _ready() -> void:
	add_to_group("fishing_spot")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	catch_timer.timeout.connect(_on_catch_timer_timeout)
	prompt.visible = false


func _process(_delta: float) -> void:
	if _player_near and not _is_fishing and Input.is_action_just_pressed("interact"):
		_start_fishing()

	prompt.visible = _player_near and not _is_fishing


func _start_fishing() -> void:
	var wait_seconds := FALLBACK_WAIT_SECONDS
	var fish_database := _fish_database()
	if fish_database != null:
		wait_seconds = float(fish_database.call("get_wait_time_seconds", spot_id))
	if wait_seconds <= 0.0:
		wait_seconds = FALLBACK_WAIT_SECONDS

	_is_fishing = true
	catch_timer.wait_time = wait_seconds
	catch_timer.start()
	fishing_started.emit(wait_seconds)


func _on_catch_timer_timeout() -> void:
	var fish_database := _fish_database()
	var inventory := _inventory()
	if fish_database == null or inventory == null:
		_is_fishing = false
		return

	var reward: Dictionary = fish_database.call("roll_reward", spot_id)
	var item_id := String(reward.get("item_id", ""))
	var amount := int(reward.get("amount", 0))
	if not item_id.is_empty() and amount > 0:
		inventory.call("add_item", item_id, amount)
		fish_caught.emit(item_id, amount)

	_is_fishing = false


func _fish_database() -> Node:
	return get_node_or_null("/root/FishDatabase")


func _inventory() -> Node:
	return get_node_or_null("/root/Inventory")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = false
