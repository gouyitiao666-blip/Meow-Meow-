extends CanvasLayer
## Pause & options menu (Phase 12.2). Esc toggles it; the game pauses while open.
## Offers Resume, Save, a master-volume slider, and Mute. Processes while paused.

var _root: Control
var _vol: HSlider
var _muted := false
var _saved_db := 0.0


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS  # work while the tree is paused
	add_to_group("pause_ui")
	_build_ui()
	close()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	if _root.visible:
		close()
	else:
		open()


func open() -> void:
	_root.show()
	get_tree().paused = true


func close() -> void:
	_root.hide()
	get_tree().paused = false


func is_open() -> bool:
	return _root.visible


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_root)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 280)
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	panel.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Paused"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var resume := Button.new()
	resume.text = "Resume"
	resume.pressed.connect(close)
	vbox.add_child(resume)

	var save_btn := Button.new()
	save_btn.text = "Save"
	save_btn.pressed.connect(_on_save)
	vbox.add_child(save_btn)

	var vol_label := Label.new()
	vol_label.text = "Master Volume"
	vbox.add_child(vol_label)
	_vol = HSlider.new()
	_vol.min_value = 0.0
	_vol.max_value = 1.0
	_vol.step = 0.05
	_vol.value = _linear_from_bus()
	_vol.value_changed.connect(_on_volume)
	vbox.add_child(_vol)

	var mute := CheckButton.new()
	mute.text = "Mute"
	mute.toggled.connect(_on_mute)
	vbox.add_child(mute)

	var quit := Button.new()
	quit.text = "Quit to Desktop"
	quit.pressed.connect(func(): get_tree().quit())
	vbox.add_child(quit)


func _on_save() -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null:
		save_manager.call("save_game")
	var toast := get_tree().get_first_node_in_group("toast_ui")
	if toast != null:
		toast.call("popup", "Saved", "Progress saved.")


func _on_volume(value: float) -> void:
	var settings := get_node_or_null("/root/SettingsManager")
	if settings != null:
		settings.call("set_volume", value)
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(maxf(value, 0.0001)))


func _on_mute(pressed: bool) -> void:
	_muted = pressed
	var settings := get_node_or_null("/root/SettingsManager")
	if settings != null:
		settings.call("set_muted", pressed)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), pressed)


func _linear_from_bus() -> float:
	var settings := get_node_or_null("/root/SettingsManager")
	if settings != null:
		return float(settings.call("get_volume"))
	return clampf(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))), 0.0, 1.0)
