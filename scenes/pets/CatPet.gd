extends Node2D
## Data-driven pet for Meow Meow ~ (Phase 2 + 6.2).
## A follower (or ambient idle animal) defined by `pet_id` in `data/pets.json`
## via the PetDatabase autoload. Intentionally NOT a physics body so it can never
## block the player. Walk art is a 4-frame sheet per direction (see SpriteSheet).

const EASE_RANGE := 64.0    ## distance over which speed eases in past the gap
const ACCEL := 8.0          ## velocity smoothing — higher = snappier, lower = floatier
const FRAME := 128
const WALK_FPS := 8.0

# Fallback art if PetDatabase / the pet's assets are unavailable (the cat).
const FALLBACK_SHEETS := {
	"down": preload("res://assets/pets/cat_walk_down.png"),
	"up": preload("res://assets/pets/cat_walk_up.png"),
	"left": preload("res://assets/pets/cat_walk_left.png"),
	"right": preload("res://assets/pets/cat_walk_right.png"),
}

@export var pet_id := "cat"
@export var follow := true  ## false = an ambient idle animal that stays put

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

## Set by World.gd. Falls back to the "player" group if left null.
var target: Node2D
var facing := "down"
var velocity := Vector2.ZERO
var _max_speed := 135.0
var _follow_gap := 48.0


func _ready() -> void:
	anim.sprite_frames = SpriteSheet.build_frames(_load_sheets(), FRAME, WALK_FPS)
	anim.play("idle_down")
	if follow and target == null:
		target = get_tree().get_first_node_in_group("player")


## Reads this pet's walk sheets + tuning from PetDatabase (by pet_id).
func _load_sheets() -> Dictionary:
	var def: Dictionary = {}
	var db := get_node_or_null("/root/PetDatabase")
	if db != null:
		def = db.call("get_pet", pet_id)

	var sheets := {}
	var walk: Dictionary = def.get("walk_assets", {})
	for dir in ["down", "up", "left", "right"]:
		var path := String(walk.get(dir, ""))
		if path != "" and ResourceLoader.exists(path):
			sheets[dir] = load(path)
	if sheets.is_empty():
		sheets = FALLBACK_SHEETS

	_max_speed = float(def.get("move_speed", 110)) + 25.0
	_follow_gap = float(def.get("follow_distance", 48))
	return sheets


func _physics_process(delta: float) -> void:
	if not follow:
		_play("idle_" + facing)  # ambient animal: just stand and breathe
		return

	if target == null:
		target = get_tree().get_first_node_in_group("player")
		return

	# Ease the target speed in with distance, then smooth the velocity so the pet
	# accelerates and stops gently instead of snapping on/off at the gap.
	var to_target := target.global_position - global_position
	var dist := to_target.length()
	var desired := Vector2.ZERO
	if dist > _follow_gap:
		var speed := _max_speed * clampf((dist - _follow_gap) / EASE_RANGE, 0.25, 1.0)
		desired = to_target / dist * speed
	velocity = velocity.lerp(desired, clampf(ACCEL * delta, 0.0, 1.0))
	global_position += velocity * delta

	if velocity.length() > 8.0:
		facing = SpriteSheet.facing_from(velocity)
		anim.speed_scale = clampf(velocity.length() / _max_speed, 0.5, 1.4)
		_play("walk_" + facing)
	else:
		anim.speed_scale = 1.0
		_play("idle_" + facing)


func _play(a: String) -> void:
	if anim.animation != a or not anim.is_playing():
		anim.play(a)
