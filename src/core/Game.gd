extends Node
class_name Game

export var player: Resource

onready var title: = $Title
onready var battle: = $Battle

func _ready() -> void:
	title.hide()
#	AudioController.play_bgm("dungeon")
	battle.initialize(player)
	battle.show()
