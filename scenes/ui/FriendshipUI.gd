extends CanvasLayer
## Friendship hearts for the follower pet (Phase 7.4). Reads the PetFriendship
## autoload and refreshes on `friendship_changed`. Owns no friendship state.

const PET_ID := "cat"
const MAX_HEARTS := 5

var _label: Label


func _ready() -> void:
	layer = 11
	_label = Label.new()
	_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_label.offset_left = 12
	_label.offset_top = -36
	add_child(_label)

	var friendship := get_node_or_null("/root/PetFriendship")
	if friendship != null:
		friendship.connect("friendship_changed", Callable(self, "_on_friendship_changed"))
	_refresh()


func _on_friendship_changed(pet_id: String, _level: int, _points: int) -> void:
	if pet_id == PET_ID:
		_refresh()


func _refresh() -> void:
	var friendship := get_node_or_null("/root/PetFriendship")
	var level := int(friendship.call("get_level", PET_ID)) if friendship != null else 0
	_label.text = "Cat  %s%s" % ["♥".repeat(level), "♡".repeat(MAX_HEARTS - level)]
