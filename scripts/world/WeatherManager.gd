extends Node
## Simple weather state for the living world (Phase 7.3).
##
## Backend autoload: owns weather IDs, daily forecast rolls, save data, and
## small crop helper methods that farming scenes can call without knowing
## visual details.

signal weather_changed(weather: String, previous_weather: String)
signal forecast_changed(next_weather: String, forecast_day: int)

const SUNNY := "sunny"
const CLOUDY := "cloudy"
const RAIN := "rain"
const STORM := "storm"
const FOG := "fog"

const WEATHER_IDS := [SUNNY, CLOUDY, RAIN, STORM, FOG]
const DEFAULT_WEATHER := SUNNY
const DEFAULT_NEXT_WEATHER := CLOUDY

const CROP_GROWTH_MULTIPLIERS := {
	SUNNY: 1.0,
	CLOUDY: 1.0,
	RAIN: 1.25,
	STORM: 1.10,
	FOG: 0.95,
}

var _current_weather := DEFAULT_WEATHER
var _next_weather := DEFAULT_NEXT_WEATHER
var _forecast_day := 2
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	var tm := get_node_or_null("/root/TimeManager")
	if tm != null and tm.has_signal("day_changed"):
		tm.connect("day_changed", Callable(self, "_on_day_changed"))


func get_weather() -> String:
	return _current_weather


func get_next_weather() -> String:
	return _next_weather


func get_forecast_day() -> int:
	return _forecast_day


func get_weather_ids() -> Array:
	return WEATHER_IDS.duplicate()


func is_valid_weather(id: String) -> bool:
	return WEATHER_IDS.has(id)


func set_weather(id: String) -> bool:
	if not is_valid_weather(id):
		return false
	if id == _current_weather:
		return true
	var previous := _current_weather
	_current_weather = id
	weather_changed.emit(_current_weather, previous)
	return true


func set_next_weather(id: String, day := 0) -> bool:
	if not is_valid_weather(id):
		return false
	_next_weather = id
	if day > 0:
		_forecast_day = day
	forecast_changed.emit(_next_weather, _forecast_day)
	return true


## Deterministic tests can seed the RNG before rolling a forecast.
func set_roll_seed(seed: int) -> void:
	_rng.seed = seed


## Rolls and stores tomorrow's weather, returning the chosen stable ID.
func roll_next_weather(day := 0) -> String:
	var roll := _rng.randf()
	var selected := SUNNY
	if roll < 0.35:
		selected = SUNNY
	elif roll < 0.60:
		selected = CLOUDY
	elif roll < 0.80:
		selected = RAIN
	elif roll < 0.92:
		selected = FOG
	else:
		selected = STORM
	set_next_weather(selected, day)
	return selected


## Called by TimeManager's day_changed signal. The forecast becomes today's
## weather, then a new forecast is rolled for the following day.
func advance_day(day: int) -> void:
	if _forecast_day <= day:
		set_weather(_next_weather)
	roll_next_weather(day + 1)


func waters_crops() -> bool:
	return _current_weather == RAIN or _current_weather == STORM


func get_crop_growth_multiplier() -> float:
	return float(CROP_GROWTH_MULTIPLIERS.get(_current_weather, 1.0))


func to_dict() -> Dictionary:
	return {
		"current": _current_weather,
		"next": _next_weather,
		"day": _forecast_day
	}


func from_dict(data: Dictionary) -> void:
	var current := String(data.get("current", DEFAULT_WEATHER))
	var next := String(data.get("next", DEFAULT_NEXT_WEATHER))
	var day: int = max(1, int(data.get("day", 2)))

	if not is_valid_weather(current):
		current = DEFAULT_WEATHER
	if not is_valid_weather(next):
		next = DEFAULT_NEXT_WEATHER

	var previous := _current_weather
	_current_weather = current
	_next_weather = next
	_forecast_day = day
	weather_changed.emit(_current_weather, previous)
	forecast_changed.emit(_next_weather, _forecast_day)


func _on_day_changed(day: int) -> void:
	advance_day(day)
