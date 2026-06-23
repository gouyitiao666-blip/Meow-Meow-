extends Node
## One-shot visual effects (Phase 12.4). `play(world_pos, texture_path)` spawns a
## short sprite that scales up + fades out, then frees itself. Used for harvest,
## planting, fishing splashes, and gathering sparkles.

func play(world_pos: Vector2, texture_path: String, duration := 0.6) -> void:
	if texture_path == "" or not ResourceLoader.exists(texture_path):
		return
	var world := _world()
	if world == null:
		return

	var sprite := Sprite2D.new()
	sprite.texture = load(texture_path)
	sprite.position = world_pos
	sprite.z_index = 50
	world.add_child(sprite)

	var tween := sprite.create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(1.4, 1.4), duration).from(Vector2(0.7, 0.7))
	tween.tween_property(sprite, "modulate:a", 0.0, duration).from(1.0)
	tween.set_parallel(false)
	tween.tween_callback(sprite.queue_free)


func _world() -> Node:
	var loop := Engine.get_main_loop()
	if loop is SceneTree:
		return (loop as SceneTree).get_first_node_in_group("world")
	return null
