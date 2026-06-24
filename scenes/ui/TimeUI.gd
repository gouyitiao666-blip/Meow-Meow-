extends CanvasLayer
## Day/night visuals (Phase 7.1): a screen tint that shifts with the time of day
## plus a small clock readout with time-of-day, weather and season icons.
## Reads the TimeManager / WeatherManager / SeasonManager autoloads; owns no
## state of its own.

const TINTS := {
	"morning": Color(1.0, 0.95, 0.80, 0.10),
	"afternoon": Color(1.0, 1.0, 1.0, 0.0),
	"evening": Color(1.0, 0.58, 0.30, 0.24),
	"night": Color(0.18, 0.22, 0.45, 0.46),
}
const TINT_LERP := 1.5  ## how fast the tint eases toward the phase target
const ICON_SIZE := Vector2(28, 28)

var _tint: ColorRect
var _clock: Label
var _time_icon: TextureRect
var _weather_icon: TextureRect
var _season_icon: TextureRect
var _target := Color(1, 1, 1, 0.0)


func _ready() -> void:
	layer = 5  # above the world, below the panels (inventory 10, shop/dialogue 12)

	_tint = ColorRect.new()
	_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tint.color = Color(1, 1, 1, 0.0)
	add_child(_tint)

	# Top-right status strip: [season][weather][time]  Day N  hh:mm — on a panel.
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.offset_left = -250
	panel.offset_top = 8
	panel.offset_right = -8
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	panel.add_child(row)

	_season_icon = _make_icon()
	row.add_child(_season_icon)
	_weather_icon = _make_icon()
	row.add_child(_weather_icon)
	_time_icon = _make_icon()
	row.add_child(_time_icon)

	_clock = Label.new()
	_clock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_clock.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_clock)

	var tm := _time()
	if tm != null:
		tm.connect("time_changed", Callable(self, "_on_time_changed"))
		tm.connect("phase_changed", Callable(self, "_on_phase_changed"))
		_target = TINTS.get(String(tm.call("get_phase")), _target)
		_tint.color = _target
		_refresh_clock()
		_refresh_time_icon(String(tm.call("get_phase")))

	var wm := get_node_or_null("/root/WeatherManager")
	if wm != null:
		wm.connect("weather_changed", Callable(self, "_on_weather_changed"))
		_refresh_weather_icon(String(wm.call("get_weather")))

	var sm := get_node_or_null("/root/SeasonManager")
	if sm != null:
		sm.connect("season_changed", Callable(self, "_on_season_changed"))
		_refresh_season_icon(String(sm.call("get_season")))


func _process(delta: float) -> void:
	_tint.color = _tint.color.lerp(_target, clampf(TINT_LERP * delta, 0.0, 1.0))


func _make_icon() -> TextureRect:
	var rect := TextureRect.new()
	rect.custom_minimum_size = ICON_SIZE
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


func _set_icon(rect: TextureRect, path: String) -> void:
	if rect == null:
		return
	if path != "" and ResourceLoader.exists(path):
		rect.texture = load(path)
		rect.visible = true
	else:
		rect.visible = false


func _on_time_changed(_minutes: float) -> void:
	_refresh_clock()


func _on_phase_changed(phase: String) -> void:
	_target = TINTS.get(phase, _target)
	_refresh_time_icon(phase)


func _on_weather_changed(weather: String, _previous := "") -> void:
	_refresh_weather_icon(weather)


func _on_season_changed(season: String) -> void:
	_refresh_season_icon(season)


func _refresh_time_icon(phase: String) -> void:
	_set_icon(_time_icon, "res://assets/ui/time_%s_icon.png" % phase)


func _refresh_weather_icon(weather: String) -> void:
	# No dedicated fog icon — fall back to the cloudy icon for fog.
	var key := "cloudy" if weather == "fog" else weather
	_set_icon(_weather_icon, "res://assets/ui/weather_%s_icon.png" % key)


func _refresh_season_icon(season: String) -> void:
	_set_icon(_season_icon, "res://assets/ui/season_%s_icon.png" % season)


func _refresh_clock() -> void:
	var tm := _time()
	if tm != null:
		_clock.text = "Day %d   %s" % [int(tm.call("get_day")), String(tm.call("get_clock_string"))]


func _time() -> Node:
	return get_node_or_null("/root/TimeManager")
