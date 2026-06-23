extends CanvasLayer
## Journal (Phase 10.1/10.3 + 11.5): a tabless overview of skills, quests
## (claimable), achievements, and collections. Toggle with J. Reads the backend
## managers; the only action is claiming completed quests.

var _root: Control
var _list: VBoxContainer


func _ready() -> void:
	layer = 13
	add_to_group("journal_ui")
	_build_ui()
	close()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_J:
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	if _root.visible:
		close()
	else:
		open()


func open() -> void:
	_refresh()
	_root.show()


func close() -> void:
	_root.hide()


func is_open() -> bool:
	return _root.visible


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.5)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(440, 460)
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	panel.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)
	var title := Label.new()
	title.text = "Journal"
	vbox.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 360)
	vbox.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 4)
	scroll.add_child(_list)
	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(close)
	vbox.add_child(close_btn)


func _heading(text: String) -> void:
	var l := Label.new()
	l.text = "— %s —" % text
	_list.add_child(l)


func _line(text: String) -> void:
	var l := Label.new()
	l.text = text
	_list.add_child(l)


func _refresh() -> void:
	for c in _list.get_children():
		c.queue_free()

	# Skills
	_heading("Skills")
	var skills := get_node_or_null("/root/SkillManager")
	if skills != null:
		for skill in ["farming", "fishing", "mining", "foraging"]:
			_line("%s  Lv %d  (%d xp)" % [skill.capitalize(), int(skills.call("get_level", skill)), int(skills.call("get_xp", skill))])

	# Quests (with claim)
	_heading("Quests")
	var quests := get_node_or_null("/root/QuestManager")
	if quests != null:
		var all: Dictionary = quests.call("get_all_quests")
		for id in all:
			var row := HBoxContainer.new()
			var lbl := Label.new()
			lbl.text = "%s  %d/%d" % [String(all[id].get("name", id)), int(quests.call("get_progress", id)), int(all[id].get("target", 1))]
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(lbl)
			if bool(quests.call("is_complete", id)) and not bool(quests.call("is_claimed", id)):
				var btn := Button.new()
				btn.text = "Claim"
				btn.pressed.connect(_claim_quest.bind(String(id)))
				row.add_child(btn)
			elif bool(quests.call("is_claimed", id)):
				var done := Label.new()
				done.text = "✓"
				row.add_child(done)
			_list.add_child(row)

	# Collections
	_heading("Collections")
	var collections := get_node_or_null("/root/CollectionManager")
	if collections != null:
		var sets: Dictionary = collections.call("get_sets")
		for set_name in sets:
			var p: Vector2i = collections.call("set_progress", set_name)
			_line("%s  %d/%d" % [set_name, p.x, p.y])

	# Achievements
	_heading("Achievements")
	var ach := get_node_or_null("/root/AchievementManager")
	if ach != null:
		var unlocked: Array = ach.call("get_unlocked")
		if unlocked.is_empty():
			_line("(none yet)")
		for id in unlocked:
			_line("★ %s" % String(ach.call("get_definition", id).get("name", id)))


func _claim_quest(id: String) -> void:
	var quests := get_node_or_null("/root/QuestManager")
	if quests != null and bool(quests.call("claim", id)):
		var toast := get_tree().get_first_node_in_group("toast_ui")
		if toast != null:
			toast.call("popup", "Quest Complete", "Reward claimed!")
	_refresh()
