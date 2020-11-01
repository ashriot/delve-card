extends Control

signal new
signal load_game

onready var new_button: Button = $BG/NewGame
onready var continue_button: Button = $BG/ContinueGame

onready var spin_box : SpinBox = $BG/SpinBox
var SAVE_KEY: String = "profile"

func initialize(game: Node) -> void:
	spin_box.value = game.profile_id as int
	if game.save_exists():
		continue_button.disabled = false
	else:
		continue_button.disabled = true

func _on_ContinueGame_button_up():
	AudioController.click()
	emit_signal("load_game")

func _on_NewGame_button_up():
	AudioController.click()
	emit_signal("new")
