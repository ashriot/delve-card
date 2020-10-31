extends Control

signal new
signal done

onready var new_button: Button = $BG/NewGame
onready var continue_button: Button = $BG/ContinueGame

onready var spin_box : SpinBox = $BG/SpinBox
var SAVE_KEY: String = "profile"
var game_saver: Node

func initialize(_game_saver: Node) -> void:
	game_saver = _game_saver
	if game_saver.exists(spin_box.value):
		continue_button.disabled = false
	else:
		continue_button.disabled = true

func _on_ContinueGame_button_up():
	AudioController.click()
	game_saver.load(spin_box.value)
	emit_signal("done")

func _on_NewGame_button_up():
	AudioController.click()
	emit_signal("new")

func save(save_game: Resource) -> void:
	print("saving profile data")
	save_game.data[SAVE_KEY] = {
		"profile_id": spin_box.value
	}

func load(save_game: Resource) -> void:
	pass
