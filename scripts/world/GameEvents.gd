extends Node
## Central gameplay event bus (Phase 10). Gameplay scenes call `report(event)`
## once; this fans the event out to the achievement, quest, and skill systems so
## those scenes don't need to know about every manager.

signal reported(event: String, amount: int)


func report(event: String, amount := 1) -> void:
	if event.is_empty():
		return
	var achievements := _autoload("AchievementManager")
	if achievements != null:
		achievements.call("record_event", event, amount)
	var quests := _autoload("QuestManager")
	if quests != null:
		quests.call("record_event", event, amount)
	var skills := _autoload("SkillManager")
	if skills != null:
		skills.call("add_event_xp", event, amount)
	reported.emit(event, amount)


func _autoload(node_name: String) -> Node:
	var loop := Engine.get_main_loop()
	if loop is SceneTree and (loop as SceneTree).root != null:
		return (loop as SceneTree).root.get_node_or_null(node_name)
	return null
