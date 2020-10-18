extends Node2D
class_name Dungeon

signal advance
signal start_battle(enemy)
signal start_loot(gold)
signal heal
signal blacksmith
signal done_pathing

onready var floor_number = $ColorRect/TopBanner/FloorNum
onready var tooltip = $ColorRect/Tooltip
onready var tooltext = $ColorRect/Tooltip/Label

onready var map = $ColorRect/Map
onready var avatar = $ColorRect/Map/Avatar as Sprite
onready var avatar_tween = $ColorRect/Map/Avatar/Tween

var current_square: Square

var progress: = 0 setget set_progress

func initialize() -> void:
	tooltip.hide()
	self.progress = 1
	current_square = map.initialize()

func reset() -> void:
	self.progress = 0
	reset_avatar()

func set_progress(value: int) -> void:
	progress = value
	floor_number.text = "Dark Forest Lv. " + str(progress) + " of 5"

func reset_avatar() -> void:
	self.progress += 1
	avatar.global_position = map.position - Vector2(8, 8)
	map.clear_map()
	yield(get_tree().create_timer(0.2), "timeout")
	current_square = map.initialize()

func path(sq: Square) -> bool:
	var from = current_square.get_index()
	var to = sq.get_index()
	var path = map.astar.get_id_path(from, to) as PoolIntArray
	if path.size() < 2:
		return false
	current_square = sq
	AudioController.steps()
	for p in path:
		avatar_tween.interpolate_property(avatar, "position",
			avatar.position,
			map.get_pos(p) - Vector2(3, 3),
			0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		avatar_tween.start()
		yield(avatar_tween, "tween_all_completed")
	emit_signal("done_pathing")
	return true

func _on_Map_move_to_square(square: Square):
	if not path(square):
		return
	yield(self, "done_pathing")
	if square.type == "Down":
		emit_signal("advance")
	if square.type == "Battle":
		var level = (progress) as int
		var enemy = load("res://src/enemies/wolf" + ".tres")
		emit_signal("start_battle", enemy)
	elif square.type == "Chest":
		emit_signal("start_loot", 0)
	elif square.type == "Rest":
		emit_signal("heal")
	elif square.type == "Anvil":
		emit_signal("blacksmith")
	if !square.cleared and square.type != "Anvil":
		square.clear()

func _on_Map_show_tooltip(button):
	tooltext.text = button.type.capitalize()
	var pos = get_global_mouse_position()
	var x = clamp(pos.x - tooltip.rect_size.x / 2, 0, 108 - tooltip.rect_size.x)
	tooltip.set_global_position(Vector2(x, pos.y - tooltip.rect_size.y - 12))
	tooltip.show()

func _on_Map_hide_tooltip():
	tooltip.hide()
