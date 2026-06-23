extends CanvasLayer
## Reusable notification toast (Phase 7.5 + general). Shows a short message at the
## top of the screen. Listens to AchievementManager so unlocks pop automatically;
## other systems (saves, festivals) can call `popup(title, subtitle)` directly.

const SHOW_SECONDS := 3.0

var _panel: PanelContainer
var _title: Label
var _subtitle: Label
var _time_left := 0.0


func _ready() -> void:
	layer = 13
	add_to_group("toast_ui")
	_build_ui()

	var achievements := get_node_or_null("/root/AchievementManager")
	if achievements != null:
		achievements.connect("achievement_unlocked", Callable(self, "_on_achievement_unlocked"))


func popup(title: String, subtitle := "") -> void:
	_title.text = title
	_subtitle.text = subtitle
	_subtitle.visible = subtitle != ""
	_panel.modulate.a = 1.0
	_panel.visible = true
	_time_left = SHOW_SECONDS


func _process(delta: float) -> void:
	if not _panel.visible:
		return
	_time_left -= delta
	if _time_left <= 0.0:
		_panel.modulate.a = maxf(0.0, _panel.modulate.a - delta * 2.0)
		if _panel.modulate.a <= 0.0:
			_panel.visible = false


func _on_achievement_unlocked(_id: String, achievement_name: String) -> void:
	popup("Achievement Unlocked!", achievement_name)


func _build_ui() -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_TOP_WIDE)
	center.offset_top = 24
	center.offset_bottom = 110
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	_panel = PanelContainer.new()
	_panel.visible = false
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(_panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_title)

	_subtitle = Label.new()
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.visible = false
	vbox.add_child(_subtitle)
