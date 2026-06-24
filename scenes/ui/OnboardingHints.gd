extends Node
## First-launch controls hint (Phase 12.3). Shows a couple of staggered toasts
## the first time a fresh game starts (no save yet), so players learn the keys.

const HINTS := [
	"Move: WASD/Arrows · Interact: E",
	"I: Bag · B: Build · J: Journal · Esc: Pause",
	"Fish at water · Farm the soil · Sleep to save",
]


func _ready() -> void:
	# Only on a fresh game (no save file), so returning players aren't nagged.
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null and bool(save_manager.call("has_save")):
		return
	_run_hints()


func _run_hints() -> void:
	for hint in HINTS:
		await get_tree().create_timer(3.2).timeout
		var toast := get_tree().get_first_node_in_group("toast_ui")
		if toast != null:
			toast.call("popup", "Tip", hint)
