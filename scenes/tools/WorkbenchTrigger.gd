extends Area2D
class_name WorkbenchTrigger
## An interact spot in front of the workbench (Phase 6.6). Stand near and press
## "interact" to open the ToolUpgradeUI. Mirrors ShopTrigger; builds its own
## collision + prompt so World can just instance it.

const TEX_PROMPT: Texture2D = preload("res://assets/ui/interact_icon.png")

var _player_near := false
var _prompt: Sprite2D


func _ready() -> void:
	monitoring = true
	collision_mask = 1

	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(160, 64)
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
	var ui := _tool_ui()
	if _player_near and Input.is_action_just_pressed("interact"):
		if ui != null and not bool(ui.call("is_open")):
			ui.call("open")
	_prompt.visible = _player_near and (ui == null or not bool(ui.call("is_open")))


func _tool_ui() -> Node:
	return get_tree().get_first_node_in_group("tool_upgrade_ui")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = false
