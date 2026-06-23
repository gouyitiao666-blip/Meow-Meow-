extends Node
## Small local money store for shops and save/load integration.

signal money_changed(new_amount: int)

var _money := 50


func get_money() -> int:
	return _money


func set_money(amount: int) -> void:
	var next_money: int = max(0, amount)
	if next_money == _money:
		return

	_money = next_money
	money_changed.emit(_money)


func add_money(amount: int) -> void:
	if amount <= 0:
		return
	set_money(_money + amount)


func can_spend(amount: int) -> bool:
	return amount >= 0 and _money >= amount


func spend_money(amount: int) -> bool:
	if amount <= 0 or not can_spend(amount):
		return false

	set_money(_money - amount)
	return true


func to_value() -> int:
	return _money


func from_value(value: int) -> void:
	set_money(value)
