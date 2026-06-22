extends Node2D
## Cat pet for Meow Meow ~ (Phase 2).
## Trails the player and idles when close. Intentionally NOT a physics body so
## it can never block the player. Walk art is a 4-frame sheet per direction,
## extracted into an AnimatedSprite2D (see SpriteSheet.gd).

const SPEED := 110.0      ## a touch slower than the player, so it gently trails
const FOLLOW_GAP := 56.0  ## only chase once the player is this far away
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


func _ready() -> void:
	anim.sprite_frames = SpriteSheet.build_frames(SHEETS, FRAME, WALK_FPS)
	anim.play("idle_down")
	if target == null:
		target = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if target == null:
		target = get_tree().get_first_node_in_group("player")
		return

	var to_target := target.global_position - global_position
	if to_target.length() > FOLLOW_GAP:
		var dir := to_target.normalized()
		global_position += dir * SPEED * delta
		facing = SpriteSheet.facing_from(dir)
		_play("walk_" + facing)
	else:
		_play("idle_" + facing)


func _play(a: String) -> void:
	if anim.animation != a or not anim.is_playing():
		anim.play(a)
