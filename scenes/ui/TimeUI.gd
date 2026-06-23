extends CanvasLayer
## Day/night visuals (Phase 7.1): a screen tint that shifts with the time of day
## plus a small clock readout. Reads the TimeManager autoload; owns no time state.

const TINTS := {
	"morning": Color(1.0, 0.95, 0.80, 0.10),
	"afternoon": Color(1.0, 1.0, 1.0, 0.0),
	"evening": Color(1.0, 0.58, 0.30, 0.24),
	"night": Color(0.18, 0.22, 0.45, 0.46),
}
const TINT_LERP := 1.5  ## how fast the tint eases toward the phase target

var _tint: ColorRect
var _clock: Label
var _target := Color(1, 1, 1, 0.0)


func _ready() -> void:
	layer = 5  # above the world, below the panels (inventory 10, shop/dialogue 12)

	_tint = ColorRect.new()
	_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tint.color = Color(1, 1, 1, 0.0)
	add_child(_tint)

	_clock = Label.new()
	_clock.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_clock.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_clock.position = Vector2(-160, 12)
	_clock.custom_minimum_size = Vector2(148, 0)
	_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_clock)

	var tm := _time()
	if tm != null:
		tm.connect("time_changed", Callable(self, "_on_time_changed"))
		tm.connect("phase_changed", Callable(self, "_on_phase_changed"))
		_target = TINTS.get(String(tm.call("get_phase")), _target)
		_tint.color = _target
		_refresh_clock()


func _process(delta: float) -> void:
	_tint.color = _tint.color.lerp(_target, clampf(TINT_LERP * delta, 0.0, 1.0))


func _on_time_changed(_minutes: float) -> void:
	_refresh_clock()


func _on_phase_changed(phase: String) -> void:
	_target = TINTS.get(phase, _target)


func _refresh_clock() -> void:
	var tm := _time()
	if tm != null:
		_clock.text = "Day %d   %s" % [int(tm.call("get_day")), String(tm.call("get_clock_string"))]


func _time() -> Node:
	return get_node_or_null("/root/TimeManager")
