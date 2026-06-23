extends Node
## Player skills (Phase 10.3): farming, fishing, mining, foraging. Each gains XP
## from gameplay events (via GameEvents) and levels up. Backend autoload; the
## Skill UI reads it via `skill_changed`. Persists via to_dict/from_dict.

signal skill_changed(skill: String, level: int, xp: int)

const SKILLS := ["farming", "fishing", "mining", "foraging"]
const XP_PER_LEVEL := 100
const MAX_LEVEL := 10

# Which gameplay event feeds which skill, and how much XP.
const EVENT_SKILL := {
	"harvest": "farming",
	"fish": "fishing",
	"mine": "mining",
	"forage": "foraging",
}
const EVENT_XP := 15

var _xp: Dictionary = {}  ## skill -> xp


func get_xp(skill: String) -> int:
	return int(_xp.get(skill, 0))


func get_level(skill: String) -> int:
	return clampi(get_xp(skill) / XP_PER_LEVEL, 0, MAX_LEVEL)


func add_xp(skill: String, amount: int) -> void:
	if amount <= 0 or not SKILLS.has(skill):
		return
	_xp[skill] = min(get_xp(skill) + amount, XP_PER_LEVEL * MAX_LEVEL)
	skill_changed.emit(skill, get_level(skill), get_xp(skill))


## Maps a gameplay event to its skill and awards XP (called by GameEvents).
func add_event_xp(event: String, amount := 1) -> void:
	var skill := String(EVENT_SKILL.get(event, ""))
	if skill != "":
		add_xp(skill, EVENT_XP * max(1, amount))


# --- Level perks (Phase 10.3) ---

## Extra crops per harvest (one more every 3 farming levels).
func harvest_bonus() -> int:
	return get_level("farming") / 3


## Extra yield when foraging (one more every 3 foraging levels).
func forage_bonus() -> int:
	return get_level("foraging") / 3


## Energy cost for a gather action, discounted by the matching skill.
func gather_energy_cost(base: int, event: String) -> int:
	var skill := ""
	if event == "mine":
		skill = "mining"
	elif event == "forage":
		skill = "foraging"
	if skill == "":
		return base
	return max(1, base - get_level(skill) / 2)


func to_dict() -> Dictionary:
	return _xp.duplicate(true)


func from_dict(data: Dictionary) -> void:
	_xp.clear()
	for skill in data:
		if SKILLS.has(String(skill)):
			_xp[String(skill)] = max(0, int(data[skill]))
	for skill in _xp:
		skill_changed.emit(skill, get_level(skill), get_xp(skill))
