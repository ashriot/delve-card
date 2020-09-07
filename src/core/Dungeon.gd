extends Node2D
class_name Dungeon

signal start_battle

onready var buttons = $ColorRect/Buttons
onready var floor_number = $ColorRect/FloorNum

onready var map = $ColorRect/Map

var progress: = 0 setget set_progress

func initialize() -> void:
	self.progress = 1
	for button in buttons.get_children():
		button.connect("button_up", self, "button_up", [button])
	map.initialize()
	map.connect("start_battle", self, "map_start_battle")

func advance() -> void:
	buttons.get_child(progress).disabled = true
	self.progress += 1
	buttons.get_child(progress).disabled = false

func button_up(button: Button) -> void:
	AudioController.click()
	var level = (1 + progress / 3) as int
	if button.text == "Encounter":
		var enemy = load("res://src/enemies/devil" + str(level) + ".tres")
		emit_signal("start_battle", enemy)

func reset() -> void:
	self.progress = 1
	for button in buttons.get_children():
		button.disabled = true
	buttons.get_child(progress).disabled = false

func set_progress(value: int) -> void:
	print("setting progress")
	progress = value
	floor_number.text = "Dark Forest Lv. " + str(progress)

func map_start_battle() -> void:
	var level = (1 + progress / 3) as int
	var enemy = load("res://src/enemies/devil" + str(level) + ".tres")
	emit_signal("start_battle", enemy)
