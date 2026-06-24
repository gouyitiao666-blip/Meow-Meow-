extends Node
## Persistent settings (Phase 14.2). Stores audio options in `user://settings.cfg`
## and applies them on launch. The pause menu reads/writes through this so choices
## survive between sessions.

const PATH := "user://settings.cfg"

var _volume := 1.0
var _muted := false


func _ready() -> void:
	load_settings()
	apply()


func get_volume() -> float:
	return _volume


func is_muted() -> bool:
	return _muted


func set_volume(value: float) -> void:
	_volume = clampf(value, 0.0, 1.0)
	apply()
	save_settings()


func set_muted(value: bool) -> void:
	_muted = value
	apply()
	save_settings()


func apply() -> void:
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(_volume, 0.0001)))
	AudioServer.set_bus_mute(bus, _muted)


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) == OK:
		_volume = clampf(float(cfg.get_value("audio", "volume", 1.0)), 0.0, 1.0)
		_muted = bool(cfg.get_value("audio", "muted", false))


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "volume", _volume)
	cfg.set_value("audio", "muted", _muted)
	cfg.save(PATH)
