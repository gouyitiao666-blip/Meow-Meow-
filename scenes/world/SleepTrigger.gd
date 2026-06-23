extends Area2D
class_name SleepTrigger
## Sleep spot by the home (Phase 11.1). Interact to skip to the next morning:
## advances the day (which refills energy, rolls weather, delivers mail) and saves.

const TEX_PROMPT: Texture2D = preload("res://assets/ui/sleep_prompt_icon.png")

var _player_near := false
var _prompt: Sprite2D


func _ready() -> void:
	monitoring = true
	collision_mask = 1
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(96, 64)
	cs.shape = shape
	add_child(cs)
	_prompt = Sprite2D.new()
	if ResourceLoader.exists(TEX_PROMPT.resource_path):
		_prompt.texture = TEX_PROMPT
	_prompt.position = Vector2(0, -56)
	_prompt.visible = false
	add_child(_prompt)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	_prompt.visible = _player_near
	if _player_near and Input.is_action_just_pressed("interact"):
		_sleep()


func _sleep() -> void:
	# Fade to black, advance the day, then fade back in (Phase 12.4).
	var layer := CanvasLayer.new()
	layer.layer = 30
	add_child(layer)
	var fade := ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(fade)

	var t1 := fade.create_tween()
	t1.tween_property(fade, "color:a", 1.0, 0.35)
	await t1.finished

	var tm := get_node_or_null("/root/TimeManager")
	if tm != null:
		var day := int(tm.call("get_day"))
		tm.call("from_dict", {"minutes": 480, "day": day + 1})  # next morning
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null:
		save_manager.call("save_game")
	var toast := get_tree().get_first_node_in_group("toast_ui")
	if toast != null:
		toast.call("popup", "A new day", "You slept well. Saved.")

	var t2 := fade.create_tween()
	t2.tween_property(fade, "color:a", 0.0, 0.35)
	await t2.finished
	layer.queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = false
