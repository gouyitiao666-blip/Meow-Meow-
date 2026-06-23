extends Node2D
## Data-driven pet for Meow Meow ~ (Phase 2 + 6.2).
## A follower OR an ambient animal, defined by `pet_id` in `data/pets.json` via
## the PetDatabase autoload. The follower trails the player and stays non-physics
## so it never blocks them (CLAUDE.md 2.4). Ambient animals (follow=false) get a
## solid footprint and roam within a small home radius. Walk art is a 4-frame
## sheet per direction (see SpriteSheet).

const EASE_RANGE := 64.0    ## distance over which speed eases in past the gap
const ACCEL := 8.0          ## velocity smoothing — higher = snappier, lower = floatier
const FRAME := 128
const WALK_FPS := 8.0
const WANDER_RADIUS := 150.0  ## ambient animals roam within this of their home
const WANDER_SPEED := 45.0
const WANDER_ARRIVE := 6.0

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

var _emote: Sprite2D
var _emote_path := ""
var _emote_cooldown := 0.0
var _emote_show := 0.0

## Set by World.gd. Falls back to the "player" group if left null.
var target: Node2D
var facing := "down"
var velocity := Vector2.ZERO
var _max_speed := 135.0
var _follow_gap := 48.0
var _home := Vector2.ZERO
var _wander_target := Vector2.ZERO
var _pause := 0.0


func _ready() -> void:
	anim.sprite_frames = SpriteSheet.build_frames(_load_sheets(), FRAME, WALK_FPS)
	anim.play("idle_down")
	_setup_emote()
	if follow:
		if target == null:
			target = get_tree().get_first_node_in_group("player")
	else:
		# Ambient animals stand still and get an invisible wall; the follower
		# stays non-physics so it never blocks the player (CLAUDE.md 2.4).
		var body := StaticBody2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(36, 18)
		var col := CollisionShape2D.new()
		col.shape = shape
		col.position = Vector2(0, -8)
		body.add_child(col)
		add_child(body)
		_home = position
		_pick_wander_target()


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
	_emote_path = String(def.get("happy_emote_asset", ""))
	return sheets


## A little heart/happy emote that pops above the pet now and then.
func _setup_emote() -> void:
	if _emote_path == "" or not ResourceLoader.exists(_emote_path):
		return
	_emote = Sprite2D.new()
	_emote.texture = load(_emote_path)
	_emote.scale = Vector2(0.5, 0.5)
	_emote.position = Vector2(0, -74)
	_emote.visible = false
	_emote.z_index = 1
	add_child(_emote)
	_emote_cooldown = randf_range(4.0, 9.0)


func _tick_emote(delta: float) -> void:
	if _emote == null:
		return
	if _emote_show > 0.0:
		_emote_show -= delta
		if _emote_show <= 0.0:
			_emote.visible = false
		return
	_emote_cooldown -= delta
	if _emote_cooldown <= 0.0:
		_emote.visible = true
		_emote_show = 1.6
		_emote_cooldown = randf_range(7.0, 13.0)


func _physics_process(delta: float) -> void:
	_tick_emote(delta)

	if not follow:
		_wander(delta)  # ambient animal: roam within a small home radius
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


## Gentle roaming for ambient animals within WANDER_RADIUS of their home.
func _wander(delta: float) -> void:
	if _pause > 0.0:
		_pause -= delta
		anim.speed_scale = 1.0
		_play("idle_" + facing)
		return

	var to := _wander_target - position
	var d := to.length()
	if d <= WANDER_ARRIVE:
		_pause = randf_range(1.2, 3.0)
		_pick_wander_target()
		_play("idle_" + facing)
		return

	var vel := to / d * WANDER_SPEED
	position += vel * delta
	facing = SpriteSheet.facing_from(vel)
	anim.speed_scale = 1.0
	_play("walk_" + facing)


func _pick_wander_target() -> void:
	var ang := randf() * TAU
	var r := sqrt(randf()) * WANDER_RADIUS
	_wander_target = _home + Vector2(cos(ang), sin(ang)) * r


## Press F near the follower to feed it its favorite treat (Phase 7.4).
func _unhandled_input(event: InputEvent) -> void:
	if not follow:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F:
		_try_feed()


func _try_feed() -> void:
	if target == null or global_position.distance_to(target.global_position) > 90.0:
		return
	var friendship := get_node_or_null("/root/PetFriendship")
	if friendship == null:
		return
	var favorite := String(friendship.call("get_favorite", pet_id))
	if favorite == "" or not bool(friendship.call("feed", pet_id, favorite)):
		return
	if _emote != null:
		_emote.visible = true
		_emote_show = 1.6
	var toast := get_tree().get_first_node_in_group("toast_ui")
	if toast != null:
		toast.call("popup", "Yum!", "%s loved the %s" % [pet_id.capitalize(), favorite])


func _play(a: String) -> void:
	if anim.animation != a or not anim.is_playing():
		anim.play(a)
