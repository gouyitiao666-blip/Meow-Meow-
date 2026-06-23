extends Node
## Time-of-day background music (Phase 7.1 "ambient sounds by time").
##
## Frontend audio wiring: plays a looping track that switches between a daytime
## and a night theme based on the TimeManager phase. Loads streams at runtime and
## guards on existence, so a missing/under-importing file never errors.

const DAY_TRACK := "res://assets/audio/333027_funky.mp3"
const NIGHT_TRACK := "res://assets/audio/268982_goofy.mp3"
const VOLUME_DB := -14.0

var _player: AudioStreamPlayer
var _current := ""


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.volume_db = VOLUME_DB
	_player.bus = "Master"
	add_child(_player)

	var tm := get_node_or_null("/root/TimeManager")
	if tm != null:
		tm.connect("phase_changed", Callable(self, "_on_phase_changed"))
		_apply(String(tm.call("get_phase")))
	else:
		_apply("morning")


func _on_phase_changed(phase: String) -> void:
	_apply(phase)


func _apply(phase: String) -> void:
	var want := "night" if phase == "night" else "day"
	if want == _current:
		return
	_current = want

	var path := NIGHT_TRACK if want == "night" else DAY_TRACK
	if not ResourceLoader.exists(path):
		return
	var stream := load(path)
	if stream is AudioStreamMP3:
		stream.loop = true
	_player.stream = stream
	_player.play()
