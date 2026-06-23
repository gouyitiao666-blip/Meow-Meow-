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


## Builds a one-direction walk cycle from a grid sheet (row-major, `frame`-px
## square cells) plus an "idle_<dir>" (first frame). Handles 1xN and NxN grids —
## used by NPCs whose walk art ships as a 2x2 grid.
static func build_single_dir(sheet: Texture2D, frame: int, fps: float, dir := "down") -> SpriteFrames:
	var sf := SpriteFrames.new()
	var walk: String = "walk_" + dir
	sf.add_animation(walk)
	sf.set_animation_speed(walk, fps)
	sf.set_animation_loop(walk, true)
	var cols := int(sheet.get_width() / frame)
	var rows := int(sheet.get_height() / frame)
	for r in range(rows):
		for c in range(cols):
			sf.add_frame(walk, _frame_tex_xy(sheet, c * frame, r * frame, frame))
	var idle: String = "idle_" + dir
	sf.add_animation(idle)
	sf.add_frame(idle, _frame_tex_xy(sheet, 0, 0, frame))
	return sf


static func _frame_tex_xy(sheet: Texture2D, x: int, y: int, size: int) -> AtlasTexture:
	var at := AtlasTexture.new()
	at.atlas = sheet
	at.region = Rect2(x, y, size, size)
	return at


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
