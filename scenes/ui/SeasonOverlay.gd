extends CanvasLayer
## Seasonal particle overlay (Phase 7.6). Tiles a gentle season texture over the
## screen, swapped on SeasonManager's `season_changed`. Reads the backend only.

const SEASON_TEX := {
	"spring": "res://assets/animated/season_spring_petals.png",
	"summer": "res://assets/animated/season_summer_fireflies.png",
	"autumn": "res://assets/animated/season_autumn_leaves.png",
	"winter": "res://assets/animated/season_winter_snowflakes.png",
}
const OVERLAY_ALPHA := 0.35

var _tex: TextureRect


func _ready() -> void:
	layer = 6  # above the day/night tint (5), below the panels
	_tex = TextureRect.new()
	_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tex.stretch_mode = TextureRect.STRETCH_TILE
	_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tex.modulate.a = OVERLAY_ALPHA
	add_child(_tex)

	var seasons := get_node_or_null("/root/SeasonManager")
	if seasons != null:
		seasons.connect("season_changed", Callable(self, "_on_season_changed"))
		_apply(String(seasons.call("get_season")))
	else:
		_apply("spring")


func _on_season_changed(season: String) -> void:
	_apply(season)


func _apply(season: String) -> void:
	var path := String(SEASON_TEX.get(season, ""))
	if path != "" and ResourceLoader.exists(path):
		_tex.texture = load(path)
		_tex.visible = true
	else:
		_tex.visible = false
