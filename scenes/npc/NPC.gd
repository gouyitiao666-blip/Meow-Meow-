extends Area2D
class_name NPC
## A villager you can talk to (Phase 6.3 + 7.2). Defined by `npc_id` in
## `data/dialogue.json` via the DialogueDatabase autoload. Stand near and press
## "interact" to open the shared DialogueUI. Has a solid footprint (invisible
## wall) and strolls within a small home radius, pausing when you talk to it.
## Builds its own sprite/collision/prompt so World can just instance it.

const TEX_PROMPT: Texture2D = preload("res://assets/ui/talk_prompt_icon.png")
const SCALE := 0.85
const FRAME := 128       ## NPC walk sheets are 2x2 grids of 128px frames
const WALK_FPS := 7.0
const WANDER_RADIUS := 120.0  ## NPCs stroll within this of their home spot
const WANDER_SPEED := 32.0
const WANDER_ARRIVE := 6.0

@export var npc_id := "villager"

var _player_near := false
var _prompt: Sprite2D
var _anim: AnimatedSprite2D
var _home := Vector2.ZERO
var _work_pos := Vector2.ZERO
var _wander_target := Vector2.ZERO
var _pause := 0.0


func _ready() -> void:
	add_to_group("npc")
	monitoring = true
	collision_mask = 1  # detect the player (CharacterBody2D on layer 1)

	var def := _npc_def()

	# Animated character, anchored so the feet sit at this node's origin (Y-sort).
	# Walk art ships as a 2x2 grid (down); idle is its first frame.
	_anim = AnimatedSprite2D.new()
	_anim.scale = Vector2(SCALE, SCALE)
	_anim.offset = Vector2(0, -FRAME / 2.0)
	var walk_path := "res://assets/npc/npc_%s_walk_down.png" % npc_id
	if not ResourceLoader.exists(walk_path):
		walk_path = String(def.get("sprite", ""))
	if ResourceLoader.exists(walk_path):
		_anim.sprite_frames = SpriteSheet.build_single_dir(load(walk_path), FRAME, WALK_FPS, "down")
		_anim.play("idle_down")
	add_child(_anim)

	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(96, 64)
	cs.shape = shape
	cs.position = Vector2(0, -16)
	add_child(cs)

	# Solid footprint so the player can't walk through the NPC (invisible wall).
	var body := StaticBody2D.new()
	var body_shape := RectangleShape2D.new()
	body_shape.size = Vector2(40, 20)
	var body_col := CollisionShape2D.new()
	body_col.shape = body_shape
	body_col.position = Vector2(0, -8)
	body.add_child(body_col)
	add_child(body)

	_prompt = Sprite2D.new()
	_prompt.texture = TEX_PROMPT
	_prompt.position = Vector2(0, -96)
	_prompt.visible = false
	add_child(_prompt)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	_home = position
	_work_pos = position
	_load_schedule()
	_pick_wander_target()


func _process(delta: float) -> void:
	var ui := _dialogue_ui()
	var talking: bool = ui != null and bool(ui.call("is_open"))
	if _player_near and Input.is_action_just_pressed("interact"):
		if ui != null and not talking:
			_turn_in_quests()
			ui.call("open", npc_id)
	_prompt.visible = _player_near and not talking

	# Stand still near the player / while talking; sleep (head home) at night;
	# otherwise stroll around home.
	if _player_near or talking:
		_idle()
		return
	if _is_night():
		_go_home(delta)
	else:
		_wander(delta)


func _walk_toward(to: Vector2) -> void:
	if _anim == null:
		return
	if _anim.animation != "walk_down" or not _anim.is_playing():
		_anim.play("walk_down")
	if absf(to.x) > 1.0:
		_anim.flip_h = to.x < 0.0


func _idle() -> void:
	if _anim != null and _anim.animation != "idle_down":
		_anim.play("idle_down")


## Claims any completed quests this NPC gave (Phase 10.1 turn-in).
func _turn_in_quests() -> void:
	var qm := get_node_or_null("/root/QuestManager")
	if qm == null:
		return
	var all: Dictionary = qm.call("get_all_quests")
	for id in all:
		if String(all[id].get("giver", "")) == npc_id and bool(qm.call("is_complete", id)) and not bool(qm.call("is_claimed", id)):
			if bool(qm.call("claim", id)):
				var toast := get_tree().get_first_node_in_group("toast_ui")
				if toast != null:
					toast.call("popup", "Quest Complete", String(all[id].get("name", id)))
				return


## Press G near an NPC to gift a flower (raises relationship). Phase 11.3.
func _unhandled_input(event: InputEvent) -> void:
	if not _player_near:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_G:
		var rel := get_node_or_null("/root/NpcRelationship")
		if rel != null and bool(rel.call("gift", npc_id, "flower")):
			var toast := get_tree().get_first_node_in_group("toast_ui")
			if toast != null:
				toast.call("popup", "Gift", "%s appreciates the flower!" % String(_npc_def().get("name", npc_id)))


func _is_night() -> bool:
	var tm := get_node_or_null("/root/TimeManager")
	return tm != null and String(tm.call("get_phase")) == "night"


## At night, walk back to the home spot and rest there.
func _go_home(delta: float) -> void:
	var to := _home - position
	var d := to.length()
	if d <= WANDER_ARRIVE:
		_idle()
		return
	position += to / d * WANDER_SPEED * delta
	_walk_toward(to)


## Gentle roaming within WANDER_RADIUS of the NPC's home spot.
func _wander(delta: float) -> void:
	if _pause > 0.0:
		_pause -= delta
		_idle()
		return
	var to := _wander_target - position
	var d := to.length()
	if d <= WANDER_ARRIVE:
		_pause = randf_range(1.5, 4.0)
		_pick_wander_target()
		_idle()
		return
	position += to / d * WANDER_SPEED * delta
	_walk_toward(to)


func _pick_wander_target() -> void:
	var ang := randf() * TAU
	var r := sqrt(randf()) * WANDER_RADIUS
	_wander_target = _anchor() + Vector2(cos(ang), sin(ang)) * r


## The spot the NPC roams around: their "work" spot during the day, "home"
## in the evening (and they walk fully home to rest at night).
func _anchor() -> Vector2:
	var tm := get_node_or_null("/root/TimeManager")
	var phase := String(tm.call("get_phase")) if tm != null else "morning"
	if phase == "morning" or phase == "afternoon":
		return _work_pos
	return _home


## Reads this NPC's work spot from data/npc_schedule.json (Phase 7.2).
func _load_schedule() -> void:
	var file := FileAccess.open("res://data/npc_schedule.json", FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var entry = parsed.get("npcs", {}).get(npc_id, {})
	if typeof(entry) == TYPE_DICTIONARY and typeof(entry.get("work")) == TYPE_DICTIONARY:
		var work: Dictionary = entry["work"]
		_work_pos = Vector2(int(work.get("x", 0)) * 64 + 32, int(work.get("y", 0)) * 64 + 32)


func _npc_def() -> Dictionary:
	var db := get_node_or_null("/root/DialogueDatabase")
	if db != null:
		return db.call("get_npc", npc_id)
	return {}


func _dialogue_ui() -> Node:
	return get_tree().get_first_node_in_group("dialogue_ui")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_near = false
