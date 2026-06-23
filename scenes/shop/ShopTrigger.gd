extends Area2D
class_name ShopTrigger
## A spot in front of a shop building. When the player stands here and presses
## "interact", it opens the ShopUI for `shop_id`. Mirrors the FishingSpot/FarmTile
## interaction pattern; builds its own collision + prompt so World can just
## instance the script.

const TEX_PROMPT: Texture2D = preload("res://assets/ui/talk_prompt_icon.png")

var shop_id := "general_store"

var _player_near := false
var _prompt: Sprite2D


func _ready() -> void:
	monitoring = true
	collision_mask = 1  # detect the player (CharacterBody2D on layer 1)

	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(192, 64)  # ~3 tiles wide, 1 tall
	cs.shape = shape
	add_child(cs)

	_prompt = Sprite2D.new()
	_prompt.texture = TEX_PROMPT
	_prompt.position = Vector2(0, -56)
	_prompt.visible = false
	add_child(_prompt)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	var ui := _shop_ui()
	if _player_near and Input.is_action_just_pressed("interact"):
		if ui != null and not bool(ui.call("is_open")):
			ui.call("open", shop_id)
	_prompt.visible = _player_near and (ui == null or not bool(ui.call("is_open")))


func _shop_ui() -> Node:
	return get_tree().get_first_node_in_group("shop_ui")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = false
