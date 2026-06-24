extends CanvasLayer
## Dialogue panel (Phase 6.3). Shows an NPC's portrait, name, and lines from the
## DialogueDatabase autoload. `open(npc_id)` starts at the greeting; pressing
## Next (or "interact") advances; it closes after the last line.

var _npc_id := ""
var _lines: Array = []
var _index := 0

var _root: Control
var _portrait: TextureRect
var _name: Label
var _text: Label


func _ready() -> void:
	layer = 12
	add_to_group("dialogue_ui")
	_build_ui()
	close()


func open(npc_id: String) -> void:
	var db := _dialogue_db()
	if db == null:
		return
	var def: Dictionary = db.call("get_npc", npc_id)
	if def.is_empty():
		return

	_npc_id = npc_id
	# Lead with a time-of-day greeting, then the NPC's greeting, a time-specific
	# remark (if any), and finally the standard lines.
	_lines = [_time_greeting(), String(def.get("greeting", ""))]
	var time_line := String(db.call("get_time_line", npc_id, _current_phase()))
	if time_line != "":
		_lines.append(time_line)
	for line in def.get("lines", []):
		_lines.append(String(line))
	_index = 0

	_name.text = String(def.get("name", "?"))
	var portrait_path := String(def.get("portrait", ""))
	_portrait.texture = load(portrait_path) if (portrait_path != "" and ResourceLoader.exists(portrait_path)) else null

	_show_line()
	_root.show()


func close() -> void:
	_root.hide()


func is_open() -> bool:
	return _root.visible


## Advance to the next line, or close past the end. Also bound to the Next button.
func advance() -> void:
	_index += 1
	if _index >= _lines.size():
		close()
	else:
		_show_line()


func _unhandled_input(event: InputEvent) -> void:
	if is_open() and event.is_action_pressed("interact"):
		advance()
		get_viewport().set_input_as_handled()


func _show_line() -> void:
	_text.text = _lines[_index] if _index < _lines.size() else ""


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	# Bottom dialogue bar.
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_left = 24
	panel.offset_right = -24
	panel.offset_top = -190
	panel.offset_bottom = -22
	# Big content margin so the portrait/text sit in the cream centre, clear of
	# the wooden frame + corner flower.
	UiSkin.apply_panel(panel, "res://assets/ui/dialogue_box.png", 34.0, 38.0)
	_root.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 4)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	margin.add_child(row)

	# Portrait sits inside a decorative frame (the frame art stretches to fill).
	var portrait_frame := PanelContainer.new()
	portrait_frame.custom_minimum_size = Vector2(96, 96)
	portrait_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UiSkin.apply_panel(portrait_frame, "res://assets/ui/npc_portrait_frame.png", 12.0, 0.0)
	row.add_child(portrait_frame)

	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(72, 72)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_frame.add_child(_portrait)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 8)
	row.add_child(col)

	# Name on a little nameplate banner.
	_name = Label.new()
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_name.custom_minimum_size = Vector2(180, 40)
	_name.add_theme_stylebox_override("normal", UiSkin.panel_box("res://assets/ui/dialogue_nameplate.png", 10.0, 18.0))
	col.add_child(_name)

	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_text)

	var next_btn := Button.new()
	next_btn.text = "Next"
	next_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	next_btn.pressed.connect(advance)
	col.add_child(next_btn)


func _current_phase() -> String:
	var tm := get_node_or_null("/root/TimeManager")
	return String(tm.call("get_phase")) if tm != null else ""


func _time_greeting() -> String:
	var tm := get_node_or_null("/root/TimeManager")
	match (String(tm.call("get_phase")) if tm != null else ""):
		"morning": return "Good morning!"
		"afternoon": return "Good afternoon."
		"evening": return "Good evening."
		"night": return "You're up late."
		_: return "Hello!"


func _dialogue_db() -> Node:
	return get_node_or_null("/root/DialogueDatabase")
