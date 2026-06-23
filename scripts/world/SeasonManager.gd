extends Node
## Seasons (Phase 7.6).
##
## Backend autoload: derives the current season from the in-game day (so it
## persists for free via the saved time), exposes seasonal crop rules, and emits
## `season_changed` for frontend visuals. Order of seasons: spring→summer→autumn→winter.

signal season_changed(season: String)

const SEASONS := ["spring", "summer", "autumn", "winter"]
const DAYS_PER_SEASON := 7

# Which crops thrive in which season (faster growth + better mood).
const SEASON_CROPS := {
	"spring": ["carrot", "strawberry"],
	"summer": ["tomato", "catnip"],
	"autumn": ["pumpkin", "carrot"],
	"winter": [],
}
const IN_SEASON_MULTIPLIER := 1.25
const OFF_SEASON_MULTIPLIER := 0.85
const WINTER_MULTIPLIER := 0.5  ## nothing is in season in winter

var _season := "spring"


func _ready() -> void:
	var tm := _autoload("TimeManager")
	if tm != null:
		tm.connect("day_changed", Callable(self, "_on_day_changed"))
		_refresh(int(tm.call("get_day")))
	else:
		_refresh(1)


func season_for_day(day: int) -> String:
	var idx: int = (int(max(1, day)) - 1) / DAYS_PER_SEASON
	return SEASONS[idx % SEASONS.size()]


func get_season() -> String:
	return _season


func get_season_index() -> int:
	return SEASONS.find(_season)


func is_in_season(crop_id: String) -> bool:
	return SEASON_CROPS.get(_season, []).has(crop_id)


## Growth-speed multiplier for a crop in the current season (frontend/farming
## can multiply grow time by 1/this, or backend crop logic can apply directly).
func get_crop_growth_multiplier(crop_id: String) -> float:
	if _season == "winter":
		return WINTER_MULTIPLIER
	return IN_SEASON_MULTIPLIER if is_in_season(crop_id) else OFF_SEASON_MULTIPLIER


func _on_day_changed(day: int) -> void:
	_refresh(day)


func _refresh(day: int) -> void:
	var s := season_for_day(day)
	if s != _season:
		_season = s
		season_changed.emit(_season)
	elif _season == "":
		_season = s


## Robust autoload lookup that works in-game and in the headless SceneTree test
## (where a node's get_tree() can be null).
func _autoload(node_name: String) -> Node:
	var loop := Engine.get_main_loop()
	if loop is SceneTree and (loop as SceneTree).root != null:
		return (loop as SceneTree).root.get_node_or_null(node_name)
	return null
