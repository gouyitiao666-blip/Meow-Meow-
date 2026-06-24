extends Area2D
class_name GatherNode
## A gatherable node (Phase 8): mine ore from rocks, forage rare plants, etc.
## Stand near and press "interact" to collect `amount` of `item_id` into the
## Inventory; the node then hides and regrows after `regen_seconds`.

const TEX_PROMPT: Texture2D = preload("res://assets/ui/interact_icon.png")

@export var item_id := "stone"
@export var amount := 1
@export var prop_path := ""
@export var regen_seconds := 25.0
@export var gather_event := "mine"  ## "mine" or "forage" (feeds quests/skills)

var _player_near := false
var _ready_to_gather := true
var _sprite: Sprite2D
var _prompt: Sprite2D
var _body_col: CollisionShape2D  ## solid footprint (invisible wall), lifts while regrowing


func _ready() -> void:
	add_to_group("gather")
	monitoring = true
	collision_mask = 1

	# Solid footprint so the rock/plant is an obstacle (Phase: obstacles for all).
	var body := StaticBody2D.new()
	_body_col = CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(44, 28)
	_body_col.shape = box
	_body_col.position = Vector2(0, -10)
	body.add_child(_body_col)
	add_child(body)

	_sprite = Sprite2D.new()
	if prop_path != "" and ResourceLoader.exists(prop_path):
		var tex: Texture2D = load(prop_path)
		_sprite.texture = tex
		var img := tex.get_image()
		var used := Rect2i(0, 0, tex.get_width(), tex.get_height())
		if img != null:
			used = img.get_used_rect()
		_sprite.offset = Vector2(0, tex.get_height() / 2.0 - float(used.position.y + used.size.y))
	add_child(_sprite)

	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(80, 64)
	cs.shape = shape
	cs.position = Vector2(0, -16)
	add_child(cs)

	_prompt = Sprite2D.new()
	_prompt.texture = TEX_PROMPT
	_prompt.position = Vector2(0, -72)
	_prompt.visible = false
	add_child(_prompt)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if _player_near and _ready_to_gather and Input.is_action_just_pressed("interact"):
		_gather()
	_prompt.visible = _player_near and _ready_to_gather


const ENERGY_COST := 6

func _gather() -> void:
	var skills := get_node_or_null("/root/SkillManager")

	# Gathering costs energy, discounted by the matching skill (Phase 9.3/10.3).
	var cost := ENERGY_COST
	if skills != null:
		cost = int(skills.call("gather_energy_cost", ENERGY_COST, gather_event))
	var energy := get_node_or_null("/root/EnergyManager")
	if energy != null and not bool(energy.call("spend", cost)):
		var t := get_tree().get_first_node_in_group("toast_ui")
		if t != null:
			t.call("popup", "Too tired", "Rest or eat something first.")
		return

	var total := amount
	if skills != null and gather_event == "forage":
		total += int(skills.call("forage_bonus"))  # foraging level perk
	var inventory := get_node_or_null("/root/Inventory")
	if inventory != null:
		inventory.call("add_item", item_id, total)
	var events := get_node_or_null("/root/GameEvents")
	if events != null:
		events.call("report", gather_event, 1)
	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("play_action"):
		var pose := "res://assets/characters/player_use_pickaxe.png" if gather_event == "mine" else "res://assets/characters/player_pickup_item.png"
		player.call("play_action", pose, 0.7)
	var fx := get_node_or_null("/root/Effects")
	if fx != null:
		fx.call("play", global_position, "res://assets/effects/item_pickup_effect.png")
	var toast := get_tree().get_first_node_in_group("toast_ui")
	if toast != null:
		toast.call("popup", "Gathered", "+%d %s" % [amount, item_id.replace("_", " ")])

	_ready_to_gather = false
	_sprite.visible = false
	_prompt.visible = false
	if _body_col != null:
		_body_col.disabled = true  # no invisible wall while it's gone
	await get_tree().create_timer(regen_seconds).timeout
	_ready_to_gather = true
	if is_instance_valid(_sprite):
		_sprite.visible = true
	if is_instance_valid(_body_col):
		_body_col.disabled = false


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = false
