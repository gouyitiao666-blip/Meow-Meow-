extends CanvasLayer
## Festival banner (Phase 7.7). Shows a banner while a festival is active and a
## Claim button that grants the festival's daily reward via FestivalManager.
## Reads the backend (FestivalManager + TimeManager); owns no festival state.

var _panel: PanelContainer
var _label: Label


func _ready() -> void:
	layer = 12
	add_to_group("festival_ui")
	_build_ui()

	var fm := get_node_or_null("/root/FestivalManager")
	if fm != null:
		fm.connect("festival_started", Callable(self, "_on_festival_started"))
		fm.connect("festival_ended", Callable(self, "_on_festival_ended"))
		var active := String(fm.call("get_active_festival"))
		if active != "":
			_on_festival_started(active, String(fm.call("get_festival", active).get("name", active)))


func _on_festival_started(_id: String, festival_name: String) -> void:
	_label.text = "🎉 %s — press Claim!" % festival_name
	_panel.visible = true


func _on_festival_ended(_id: String) -> void:
	_panel.visible = false


func _claim() -> void:
	var fm := get_node_or_null("/root/FestivalManager")
	var tm := get_node_or_null("/root/TimeManager")
	if fm == null or tm == null:
		return
	var ok: bool = fm.call("claim_reward", int(tm.call("get_day")))
	var toast := get_tree().get_first_node_in_group("toast_ui")
	if toast != null:
		toast.call("popup", "Festival" if ok else "Already claimed", "Reward collected!" if ok else "Come back tomorrow.")


func _build_ui() -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_TOP_WIDE)
	center.offset_top = 120
	center.offset_bottom = 190
	add_child(center)

	_panel = PanelContainer.new()
	_panel.visible = false
	center.add_child(_panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	_panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	margin.add_child(row)

	_label = Label.new()
	row.add_child(_label)

	var claim := Button.new()
	claim.text = "Claim"
	claim.pressed.connect(_claim)
	row.add_child(claim)
