extends Node2D
class_name Dungeon

signal advance
signal start_battle(enemy)
signal start_loot(gold)
signal heal
signal blacksmith

onready var floor_number = $ColorRect/TopBanner/FloorNum
onready var tooltip = $ColorRect/Tooltip
onready var tooltext = $ColorRect/Tooltip/Label

onready var map = $ColorRect/Map
onready var avatar = $ColorRect/Avatar

var progress: = 0 setget set_progress

func initialize() -> void:
	tooltip.hide()
	self.progress = 1
	map.initialize()

func advance() -> void:
	self.progress += 1

func reset() -> void:
	self.progress = 0
	reset_avatar()

func set_progress(value: int) -> void:
	progress = value
	floor_number.text = "Dark Forest Lv. " + str(progress) + " of 5"

func reset_avatar() -> void:
	self.progress += 1
	avatar.global_position = map.position - Vector2(8, 8)
	map.	load_map()

func _on_Map_start_battle():
	var level = (progress) as int
	var enemy = load("res://src/enemies/devil" + str(level) + ".tres")
	emit_signal("start_battle", enemy)

func _on_Map_start_loot():
	print("Dungeon received loot signal")
	emit_signal("start_loot", 0)

func _on_Map_heal():
	emit_signal("heal")

func _on_Map_show_tooltip(button):
	tooltext.text = button.type.capitalize()
	var pos = get_global_mouse_position()
	var x = clamp(pos.x - tooltip.rect_size.x / 2, 0, 108 - tooltip.rect_size.x)
	tooltip.set_global_position(Vector2(x, pos.y - tooltip.rect_size.y - 12))
	tooltip.show()

func _on_Map_hide_tooltip():
	tooltip.hide()

func _on_Map_move_to_square(square: Square):
	avatar.global_position = square.rect_global_position - Vector2(3, 3)

func _on_Map_advance():
	emit_signal("advance")

func _on_Map_blacksmith():
	emit_signal("blacksmith")
