extends Node2D
class_name Dungeon

signal start_battle

onready var buttons = $TextureRect/Buttons

var progress: = 1

func initialize() -> void:
	for button in buttons.get_children():
		button.connect("button_up", self, "button_up", [button])

func advance() -> void:
	buttons.get_child(progress).disabled = true
	progress += 1
	buttons.get_child(progress).disabled = false

func button_up(button: Button) -> void:
	AudioController.click()
	var level = (1 + progress / 3) as int
	if button.text == "Encounter":
		var enemy = load("res://src/enemies/devil" + str(level) + ".tres")
		emit_signal("start_battle", enemy)

func reset() -> void:
	progress = 1
	for button in buttons.get_children():
		button.disabled = true
	buttons.get_child(progress).disabled = false
