extends Node2D
## Cat pet for Meow Meow ~ (Phase 2).
## Trails the player and idles when close. Intentionally NOT a physics body so
## it can never block the player. Walk art is a 4-frame sheet per direction,
## extracted into an AnimatedSprite2D (see SpriteSheet.gd).

const MAX_SPEED := 135.0    ## top chase speed (catches up to the 120-speed player)
const FOLLOW_GAP := 48.0    ## only chase once the player is this far away
const EASE_RANGE := 64.0    ## distance over which speed eases in past the gap
const ACCEL := 8.0          ## velocity smoothing — higher = snappier, lower = floatier
const FRAME := 128
const WALK_FPS := 8.0

const SHEETS := {
	"down": preload("res://assets/pets/cat_walk_down.png"),
	"up": preload("res://assets/pets/cat_walk_up.png"),
	"left": preload("res://assets/pets/cat_walk_left.png"),
	"right": preload("res://assets/pets/cat_walk_right.png"),
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

## Set by World.gd. Falls back to the "player" group if left null.
var target: Node2D
var facing := "down"
var velocity := Vector2.ZERO


func _ready() -> void:
	anim.sprite_frames = SpriteSheet.build_frames(SHEETS, FRAME, WALK_FPS)
	anim.play("idle_down")
	if target == null:
		target = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if target == null:
		target = get_tree().get_first_node_in_group("player")
		return

	# Ease the target speed in with distance, then smooth the velocity so the cat
	# accelerates and stops gently instead of snapping on/off at the gap.
	var to_target := target.global_position - global_position
	var dist := to_target.length()
	var desired := Vector2.ZERO
	if dist > FOLLOW_GAP:
		var speed := MAX_SPEED * clampf((dist - FOLLOW_GAP) / EASE_RANGE, 0.25, 1.0)
		desired = to_target / dist * speed
	velocity = velocity.lerp(desired, clampf(ACCEL * delta, 0.0, 1.0))
	global_position += velocity * delta

	if velocity.length() > 8.0:
		facing = SpriteSheet.facing_from(velocity)
		anim.speed_scale = clampf(velocity.length() / MAX_SPEED, 0.5, 1.4)
		_play("walk_" + facing)
	else:
		anim.speed_scale = 1.0
		_play("idle_" + facing)


func _play(a: String) -> void:
	if anim.animation != a or not anim.is_playing():
		anim.play(a)
