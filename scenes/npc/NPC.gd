extends Area2D
class_name NPC
## A villager you can talk to (Phase 6.3). Defined by `npc_id` in
## `data/dialogue.json` via the DialogueDatabase autoload. Stand near and press
## "interact" to open the shared DialogueUI. Non-physics, so it never blocks the
## player. Builds its own sprite/collision/prompt so World can just instance it.

const TEX_PROMPT: Texture2D = preload("res://assets/ui/talk_prompt_icon.png")
const SCALE := 0.85

@export var npc_id := "villager"

var _player_near := false
var _prompt: Sprite2D


func _ready() -> void:
	add_to_group("npc")
	monitoring = true
	collision_mask = 1  # detect the player (CharacterBody2D on layer 1)

	var def := _npc_def()

	# Character sprite, anchored so the feet sit at this node's origin (Y-sort).
	var sprite := Sprite2D.new()
	var sprite_path := String(def.get("sprite", ""))
	if sprite_path != "" and ResourceLoader.exists(sprite_path):
		sprite.texture = load(sprite_path)
		sprite.scale = Vector2(SCALE, SCALE)
		sprite.offset = Vector2(0, -sprite.texture.get_height() / 2.0)
	add_child(sprite)

	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(96, 64)
	cs.shape = shape
	cs.position = Vector2(0, -16)
	add_child(cs)

	_prompt = Sprite2D.new()
	_prompt.texture = TEX_PROMPT
	_prompt.position = Vector2(0, -96)
	_prompt.visible = false
	add_child(_prompt)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	var ui := _dialogue_ui()
	if _player_near and Input.is_action_just_pressed("interact"):
		if ui != null and not bool(ui.call("is_open")):
			ui.call("open", npc_id)
	_prompt.visible = _player_near and (ui == null or not bool(ui.call("is_open")))


func _npc_def() -> Dictionary:
	var db := get_node_or_null("/root/DialogueDatabase")
	if db != null:
		return db.call("get_npc", npc_id)
	return {}


func _dialogue_ui() -> Node:
	return get_tree().get_first_node_in_group("dialogue_ui")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = false
