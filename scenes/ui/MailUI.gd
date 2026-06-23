extends CanvasLayer
## Mailbox panel (Phase 10.2). Lists letters; claim attachments (coins/items).
## Reads MailManager; opened by a UiTrigger on the mailbox.

var _root: Control
var _list: VBoxContainer


func _ready() -> void:
	layer = 12
	add_to_group("mail_ui")
	_build_ui()
	close()
	var mail := _mail()
	if mail != null:
		mail.connect("mail_changed", Callable(self, "_on_changed"))


func open() -> void:
	_refresh()
	_root.show()


func close() -> void:
	_root.hide()


func is_open() -> bool:
	return _root.visible


func claim(index: int) -> bool:
	var mail := _mail()
	if mail == null:
		return false
	var ok: bool = mail.call("claim", index)
	if ok:
		var toast := get_tree().get_first_node_in_group("toast_ui")
		if toast != null:
			toast.call("popup", "Mail", "Attachment claimed!")
	_refresh()
	return ok


func _on_changed() -> void:
	if is_open():
		_refresh()


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
	panel.custom_minimum_size = Vector2(420, 400)
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	panel.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)
	var title := Label.new()
	title.text = "Mailbox"
	vbox.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 300)
	vbox.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_list)
	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(close)
	vbox.add_child(close_btn)


func _refresh() -> void:
	for c in _list.get_children():
		c.queue_free()
	var mail := _mail()
	if mail == null:
		return
	var letters: Array = mail.call("get_mail")
	if letters.is_empty():
		var none := Label.new()
		none.text = "(no mail)"
		_list.add_child(none)
		return
	for i in range(letters.size()):
		var letter: Dictionary = letters[i]
		var row := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = "%s — %s" % [String(letter.get("title", "")), String(letter.get("body", ""))]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(lbl)
		if bool(letter.get("claimed", false)):
			var done := Label.new()
			done.text = "✓"
			row.add_child(done)
		else:
			var btn := Button.new()
			btn.text = "Claim"
			btn.pressed.connect(claim.bind(i))
			row.add_child(btn)
		_list.add_child(row)


func _mail() -> Node:
	return get_node_or_null("/root/MailManager")
