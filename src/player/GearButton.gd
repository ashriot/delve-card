extends Button
class_name GearButton

onready var chosen: = false setget set_chosen
onready var sprite: = $Sprite

var level_req setget, get_level_req
var cost setget, get_cost

var gear: Gear
var desc: String setget, get_desc

func initialize(_gear: Gear):
	$Chosen.hide()
	gear = _gear
	text = gear.name
	$Chosen/Label.text = gear.name
	if gear.unlocked:
		$Lock.hide()
		$Chosen/Lock.hide()
	else:
		$Lock.show()
		$Chosen/Lock.show()
	if gear.build:
		$Sprite.hide()
		$Badge.show()
		$Chosen/Sprite.hide()
		$Chosen/Badge.show()

func unlock() -> void:
	gear.unlocked = true
	$Lock.hide()
	$Chosen/Lock.hide()

func equip() -> void:
	$Equipped.show()
	$Chosen/Equipped.show()

func unequip() -> void:
	$Equipped.hide()
	$Chosen/Equipped.hide()

func set_chosen(value) -> void:
	chosen = value
	if chosen: $Chosen.show()
	else: $Chosen.hide()

func clear() -> void:
	chosen = false
	gear = null
	hide()

func fade() -> void:
	show()
	chosen = false
	modulate.r = 0.5
	modulate.g = 0.5
	modulate.b = 0.5

func opaque() -> void:
	show()
	chosen = false
	modulate.r = 1
	modulate.g = 1
	modulate.b = 1

func get_desc() -> String:
	return gear.desc

func get_level_req() -> int:
	return gear.level_req

func get_cost() -> int:
	return gear.cost
