extends Node
## Mailbox (Phase 10.2): a small list of letters, some with attachments (coins/
## items). A new letter arrives each in-game day. Backend autoload; the Mail UI
## reads it and claims attachments. Persists via to_dict/from_dict.

signal mail_changed()

const DAILY_LETTERS := [
	{"title": "Welcome!", "body": "Enjoy your cozy days here.", "money": 20, "items": {}},
	{"title": "From the Farmer", "body": "Some seeds to get you started.", "money": 0, "items": {"carrot_seed": 3}},
	{"title": "Fisher's Tip", "body": "The pond hides unusual fish.", "money": 10, "items": {}},
	{"title": "Shopkeeper", "body": "Thanks for visiting the store!", "money": 0, "items": {"pet_food": 1}},
]

var _mail: Array = []
var _next_index := 0


func _ready() -> void:
	if _mail.is_empty():
		_add_letter(0)  # welcome letter on first run
	var tm := _autoload("TimeManager")
	if tm != null:
		tm.connect("day_changed", Callable(self, "_on_day_changed"))


func get_mail() -> Array:
	return _mail.duplicate(true)


func unread_count() -> int:
	var n := 0
	for m in _mail:
		if not bool(m.get("claimed", false)):
			n += 1
	return n


## Claims a letter's attachments (coins + items) and marks it read.
func claim(index: int) -> bool:
	if index < 0 or index >= _mail.size() or bool(_mail[index].get("claimed", false)):
		return false
	var wallet := _autoload("Wallet")
	if wallet != null:
		wallet.call("add_money", int(_mail[index].get("money", 0)))
	var inventory := _autoload("Inventory")
	if inventory != null:
		for item_id in _mail[index].get("items", {}):
			inventory.call("add_item", item_id, int(_mail[index]["items"][item_id]))
	_mail[index]["claimed"] = true
	mail_changed.emit()
	return true


func _on_day_changed(_day: int) -> void:
	_add_letter(_next_index)


func _add_letter(template_index: int) -> void:
	var t: Dictionary = DAILY_LETTERS[template_index % DAILY_LETTERS.size()].duplicate(true)
	t["claimed"] = false
	_mail.append(t)
	_next_index = (template_index + 1) % DAILY_LETTERS.size()
	mail_changed.emit()


func to_dict() -> Dictionary:
	return {"mail": _mail.duplicate(true), "next": _next_index}


func from_dict(data: Dictionary) -> void:
	if typeof(data.get("mail")) == TYPE_ARRAY:
		_mail = data["mail"].duplicate(true)
	_next_index = int(data.get("next", 0))
	mail_changed.emit()


func _autoload(node_name: String) -> Node:
	var loop := Engine.get_main_loop()
	if loop is SceneTree and (loop as SceneTree).root != null:
		return (loop as SceneTree).root.get_node_or_null(node_name)
	return null
