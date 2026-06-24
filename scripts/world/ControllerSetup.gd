extends Node
## Gamepad support (Phase 14.3). Adds joypad buttons + left-stick axes to the
## existing input actions at startup, so controllers work without editing the
## keyboard mappings in project.godot.

func _ready() -> void:
	_add_button("move_up", JOY_BUTTON_DPAD_UP)
	_add_button("move_down", JOY_BUTTON_DPAD_DOWN)
	_add_button("move_left", JOY_BUTTON_DPAD_LEFT)
	_add_button("move_right", JOY_BUTTON_DPAD_RIGHT)
	_add_button("interact", JOY_BUTTON_A)
	_add_button("inventory", JOY_BUTTON_Y)
	_add_button("pause", JOY_BUTTON_START)
	# Left stick for movement.
	_add_axis("move_left", "move_right", JOY_AXIS_LEFT_X)
	_add_axis("move_up", "move_down", JOY_AXIS_LEFT_Y)


func _add_button(action: String, button: int) -> void:
	if not InputMap.has_action(action):
		return
	var event := InputEventJoypadButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)


func _add_axis(neg_action: String, pos_action: String, axis: int) -> void:
	if InputMap.has_action(neg_action):
		var neg := InputEventJoypadMotion.new()
		neg.axis = axis
		neg.axis_value = -1.0
		InputMap.action_add_event(neg_action, neg)
	if InputMap.has_action(pos_action):
		var pos := InputEventJoypadMotion.new()
		pos.axis = axis
		pos.axis_value = 1.0
		InputMap.action_add_event(pos_action, pos)
