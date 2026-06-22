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


func _ready() -> void:
	add_to_group("player")
	anim.sprite_frames = SpriteSheet.build_frames(SHEETS, FRAME, WALK_FPS)
	anim.play("idle_down")


func _physics_process(_delta: float) -> void:
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
