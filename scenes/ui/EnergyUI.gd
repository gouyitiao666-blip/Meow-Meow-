extends CanvasLayer
## Energy bar (Phase 9.3). Reads the EnergyManager autoload and updates on
## `energy_changed`. Top-left, under the friendship hearts.

var _bar: ProgressBar
var _label: Label


func _ready() -> void:
	layer = 11
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_TOP_LEFT)
	box.offset_left = 12
	box.offset_top = 12
	box.custom_minimum_size = Vector2(150, 0)
	add_child(box)

	_label = Label.new()
	box.add_child(_label)

	_bar = ProgressBar.new()
	_bar.custom_minimum_size = Vector2(150, 14)
	_bar.show_percentage = false
	box.add_child(_bar)

	var energy := _energy()
	if energy != null:
		energy.connect("energy_changed", Callable(self, "_on_energy_changed"))
		_bar.max_value = int(energy.call("get_max_energy"))
		_refresh(int(energy.call("get_energy")), int(energy.call("get_max_energy")))


func _on_energy_changed(value: int, max_value: int) -> void:
	_refresh(value, max_value)


func _refresh(value: int, max_value: int) -> void:
	_bar.max_value = max_value
	_bar.value = value
	_label.text = "Energy %d/%d" % [value, max_value]


func _energy() -> Node:
	return get_node_or_null("/root/EnergyManager")
