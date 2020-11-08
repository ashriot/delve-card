extends BaseControl
class_name Blacksmith

signal open_deck(amt, type)

onready var upgrade = $BG/Choices/Upgrade
onready var destroy = $BG/Choices/Destroy
onready var destroy_label = $BG/Choices/Destroy/Cost

var upgrade_cost: = 0
var destroy_increase: = 10
var destroy_cost: = 0

var upgrading: = false
var destroying: = false

var cost: int setget , get_cost

func initialize(game) -> void:
	if game.loading:
		upgrade_cost = game.game_data.upgrade_cost
		destroy_cost = game.game_data.destroy_cost
	connect("open_deck", game, "blacksmithing_deck")
	destroy_label.text = str(destroy_cost)
	upgrade.disabled = true

func get_cost() -> int:
	return upgrade_cost if upgrading else destroy_cost

func destroy_card() -> void:
	destroy_cost += destroy_increase
	destroy_label.text = str(destroy_cost)

func show(move: = true) -> void:
	$BG/Choices/Exit.mouse_filter = Control.MOUSE_FILTER_STOP
	AudioController.click()
	.show(move)

func _on_Upgrade_button_up():
	AudioController.click()
	upgrading = true
	destroying = false
	emit_signal("open_deck", self)

func _on_Destroy_button_up():
	AudioController.click()
	upgrading = false
	destroying = true
	emit_signal("open_deck", self)

func _on_Exit_button_up():
	$BG/Choices/Exit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.back()
	hide()
