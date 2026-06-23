extends Node
## In-game day/night clock (Phase 7.1).
##
## Advances time automatically, exposes the current phase + a clock string, and
## persists through SaveManager (to_dict/from_dict). One in-game day runs in
## `DAY_REAL_SECONDS` real seconds. Backend system (autoload) per AGENTS.md;
## the frontend TimeUI reads it via signals.

signal time_changed(minutes: float)
signal phase_changed(phase: String)
signal day_changed(day: int)

const MINUTES_PER_DAY := 1440
const DAY_REAL_SECONDS := 600.0  ## one in-game day = 10 real minutes
const START_MINUTES := 480.0     ## start at 08:00

var _minutes := START_MINUTES
var _day := 1
var _phase := ""
var _paused := false


func _ready() -> void:
	_phase = _phase_for(_minutes)


func _process(delta: float) -> void:
	if _paused:
		return
	advance(delta * float(MINUTES_PER_DAY) / DAY_REAL_SECONDS)


## Advances the clock by `mins` in-game minutes, rolling over days and emitting
## time/phase/day signals as needed.
func advance(mins: float) -> void:
	if mins <= 0.0:
		return
	_minutes += mins
	while _minutes >= MINUTES_PER_DAY:
		_minutes -= MINUTES_PER_DAY
		_day += 1
		day_changed.emit(_day)
	time_changed.emit(_minutes)

	var p := _phase_for(_minutes)
	if p != _phase:
		_phase = p
		phase_changed.emit(_phase)


func set_paused(paused: bool) -> void:
	_paused = paused


func get_minutes() -> float:
	return _minutes


func get_day() -> int:
	return _day


func get_phase() -> String:
	return _phase


func get_hour() -> int:
	return int(_minutes / 60.0)


func get_day_fraction() -> float:
	return _minutes / float(MINUTES_PER_DAY)


## 12-hour clock string, e.g. "8:05 AM".
func get_clock_string() -> String:
	var h := int(_minutes / 60.0)
	var m := int(_minutes) % 60
	var suffix := "AM" if h < 12 else "PM"
	var h12 := h % 12
	if h12 == 0:
		h12 = 12
	return "%d:%02d %s" % [h12, m, suffix]


func _phase_for(minutes: float) -> String:
	var h := minutes / 60.0
	if h >= 5.0 and h < 12.0:
		return "morning"
	if h >= 12.0 and h < 18.0:
		return "afternoon"
	if h >= 18.0 and h < 21.0:
		return "evening"
	return "night"


func to_dict() -> Dictionary:
	return {"minutes": _minutes, "day": _day}


func from_dict(data: Dictionary) -> void:
	_minutes = clampf(float(data.get("minutes", START_MINUTES)), 0.0, float(MINUTES_PER_DAY) - 1.0)
	_day = max(1, int(data.get("day", 1)))
	_phase = _phase_for(_minutes)
	time_changed.emit(_minutes)
	phase_changed.emit(_phase)
	day_changed.emit(_day)
