extends Button
class_name TraitButton

onready var chosen: = false setget set_chosen

var perk: Perk
var desc: String setget , get_desc
var picked: bool

func initialize(_perk: Perk):
	$Chosen.hide()
	perk = _perk
	text = perk.name
	picked = false
	$Ranks.text = "*" if chosen else ""
	$Chosen/Label.text = perk.name
	$Chosen/Ranks.text = "*" if chosen else ""

func set_chosen(value) -> void:
	chosen = value
	if chosen:
		$Chosen.show()
	else:
		$Chosen.hide()

func clear() -> void:
	chosen = false
	perk = null
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
	return perk.desc
