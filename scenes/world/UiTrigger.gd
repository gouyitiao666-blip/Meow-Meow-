extends Area2D
class_name UiTrigger
## A generic "stand near + interact to open a UI" spot (Phase 10). Opens the
## node in `ui_group` via its `open()` method. Used by the museum and mailbox.

const TEX_PROMPT: Texture2D = preload("res://assets/ui/interact_icon.png")

@export var ui_group := ""

var _player_near := false
var _prompt: Sprite2D


func _ready() -> void:
	monitoring = true
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(140, 64)
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
	var ui := get_tree().get_first_node_in_group(ui_group)
	if _player_near and Input.is_action_just_pressed("interact"):
		if ui != null and not bool(ui.call("is_open")):
			ui.call("open")
	_prompt.visible = _player_near and (ui == null or not bool(ui.call("is_open")))


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = false
