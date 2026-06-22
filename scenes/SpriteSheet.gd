class_name SpriteSheet
extends RefCounted
## Frontend helper: turns horizontal sprite sheets into AnimatedSprite2D frames.
## Used by Player.gd and CatPet.gd so the walk-cycle extraction lives in one place.

## Builds, per direction, a looping "walk_<dir>" animation plus a single-frame
## "idle_<dir>" (frame 0). `sheets` maps "down"/"up"/"left"/"right" -> Texture2D,
## each a row of `frame`x`frame` cells.
static func build_frames(sheets: Dictionary, frame: int, fps: float) -> SpriteFrames:
	var sf := SpriteFrames.new()
	for dir in sheets:
		var sheet: Texture2D = sheets[dir]
		var count := int(sheet.get_width() / frame)
		var walk: String = "walk_" + String(dir)
		sf.add_animation(walk)
		sf.set_animation_speed(walk, fps)
		sf.set_animation_loop(walk, true)
		for i in count:
			sf.add_frame(walk, _frame_tex(sheet, i * frame, frame))
		var idle: String = "idle_" + String(dir)
		sf.add_animation(idle)
		sf.add_frame(idle, _frame_tex(sheet, 0, frame))
	return sf


## Maps a movement vector to "up"/"down"/"left"/"right" by dominant axis.
static func facing_from(dir: Vector2) -> String:
	if absf(dir.x) > absf(dir.y):
		return "right" if dir.x > 0.0 else "left"
	return "down" if dir.y > 0.0 else "up"


static func _frame_tex(sheet: Texture2D, x: int, size: int) -> AtlasTexture:
	var at := AtlasTexture.new()
	at.atlas = sheet
	at.region = Rect2(x, 0, size, size)
	return at
