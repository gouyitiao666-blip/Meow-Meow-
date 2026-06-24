extends CharacterBody2D
## Player controller for Meow Meow ~ (Phase 1).
## Walk art ships as 4-frame sprite sheets (512x128) per direction. This script
## EXTRACTS those frames into an AnimatedSprite2D — playing a walk cycle while
## moving and a standing (frame 0) idle when still, facing the last direction.

const SPEED := 120.0
const FRAME := 128    ## one walk frame is 128x128
const WALK_FPS := 8.0

const SHEETS := {
	"down": preload("res://assets/characters/player_walk_down.png"),
	"up": preload("res://assets/characters/player_walk_up.png"),
	"left": preload("res://assets/characters/player_walk_left.png"),
	"right": preload("res://assets/characters/player_walk_right.png"),
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var facing := "down"
var _action_sprite: Sprite2D
var _action_time := 0.0


func _ready() -> void:
	add_to_group("player")
	anim.sprite_frames = SpriteSheet.build_frames(SHEETS, FRAME, WALK_FPS)
	anim.play("idle_down")

	# A pose sprite shown during actions (fishing/farming/mining/foraging).
	# Scale/offset are set per-texture in play_action so poses match the body.
	_action_sprite = Sprite2D.new()
	_action_sprite.visible = false
	add_child(_action_sprite)


## Shows an action pose for `seconds` (the player stands still meanwhile).
## `pose_path` is a character action texture; ignored if missing.
func play_action(pose_path: String, seconds := 0.8) -> void:
	if pose_path == "" or not ResourceLoader.exists(pose_path):
		return
	var tex: Texture2D = load(pose_path)
	_action_sprite.texture = tex
	# Action poses ship at 64px while the walk body is a 128px frame; scale the
	# pose up to match and keep its feet on the same origin (offset -28 at 128px).
	var h := tex.get_height()
	var s := 128.0 / float(h) if h > 0 else 1.0
	_action_sprite.scale = Vector2(s, s)
	_action_sprite.offset = Vector2(0, -28.0 / s)
	_action_sprite.flip_h = facing == "left"
	_action_sprite.visible = true
	anim.visible = false
	_action_time = seconds


func is_busy() -> bool:
	return _action_time > 0.0


func _physics_process(delta: float) -> void:
	# During an action pose, stand still and hold the pose.
	if _action_time > 0.0:
		velocity = Vector2.ZERO
		_action_time -= delta
		if _action_time <= 0.0:
			_action_sprite.visible = false
			anim.visible = true
		return

	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * SPEED
	move_and_slide()
	if dir != Vector2.ZERO:
		facing = SpriteSheet.facing_from(dir)
		_play("walk_" + facing)
	else:
		_play("idle_" + facing)


func _play(a: String) -> void:
	if anim.animation != a or not anim.is_playing():
		anim.play(a)
