extends CanvasLayer
## Energy bar (Phase 9.3). Reads the EnergyManager autoload and updates on
## `energy_changed`. Top-left, under the friendship hearts.

var _bar: ProgressBar
var _label: Label
var _icon: TextureRect


func _ready() -> void:
	layer = 11
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_TOP_LEFT)
	box.offset_left = 12
	box.offset_top = 12
	box.custom_minimum_size = Vector2(150, 0)
	add_child(box)

	# Icon + label on one row, with the bar below.
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	box.add_child(row)

	_icon = TextureRect.new()
	_icon.custom_minimum_size = Vector2(22, 22)
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_icon)

	_label = Label.new()
	_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_label)

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
	# Swap the icon to reflect how much energy is left.
	var ratio := float(value) / float(max_value) if max_value > 0 else 0.0
	var icon_path := "res://assets/ui/energy_icon.png"
	if ratio <= 0.25:
		icon_path = "res://assets/ui/energy_low_icon.png"
	elif ratio >= 0.99:
		icon_path = "res://assets/ui/energy_full_icon.png"
	if _icon != null and ResourceLoader.exists(icon_path):
		_icon.texture = load(icon_path)


func _energy() -> Node:
	return get_node_or_null("/root/EnergyManager")
