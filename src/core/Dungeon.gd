extends Node2D
class_name Dungeon

signal blank
signal advance
signal start_battle(enemy)
signal start_loot(gold)
signal heal
signal blacksmith
signal done_pathing

onready var floor_number = $ColorRect/TopBanner/FloorNum
onready var tooltip = $ColorRect/Tooltip
onready var tooltext = $ColorRect/Tooltip/Label

onready var map = $Map
onready var avatar = $Avatar as Sprite
onready var avatar_tween = $Avatar/Tween
onready var colorRect = $ColorRect

var SAVE_KEY: String = "dungeon"
var current_square: int
var game_seed: String

var progress: = 0 setget set_progress

func initialize(game) -> void:
	print("dungeon.initialize()")
	game_seed = game.game_seed
	tooltip.hide()
	map.connect("move_to_square", self, "_on_Map_move_to_square", [], 2)
	self.progress = 1

func new_map() -> void:
	print("dungeon.new_map()")
	map.initialize()
	var origin = map.get_origin()
	current_square = origin.get_index()

func reset() -> void:
	self.progress = 0
	reset_avatar()

func set_progress(value: int) -> void:
	progress = value
	floor_number.text = "Dark Forest Lv. " + str(progress) + " of 5"

# Advance -> Stairs Down
func reset_avatar() -> void:
	self.progress += 1
	avatar.global_position = map.position - Vector2(8, 8)
	map.clear_map()
	yield(get_tree().create_timer(0.2), "timeout")
	new_map()
	var origin = map.get_origin()
	current_square = origin.get_index()

func path(sq: Square) -> bool:
	var from = current_square
	var to = sq.get_index()
	var path = map.astar.get_id_path(from, to) as PoolIntArray
	if path.size() < 2:
		return false
	current_square = to
	print(current_square)
	print(map.squares.get_child(to))
	AudioController.steps()
	for p in path:
		avatar_tween.interpolate_property(avatar, "position",
			avatar.position,
			map.get_pos(p) - Vector2(3, 3) + map.position,
			0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		avatar_tween.start()
		yield(avatar_tween, "tween_all_completed")
	emit_signal("done_pathing")
	return true

func _on_Map_move_to_square(square: Square):
	print("trying to move")
	var moving = path(square)
	if not moving and square.type != "Anvil":
		return
	if moving:
		yield(self, "done_pathing")
	if square.type == "Clear":
		emit_signal("blank")
	elif square.type == "Down":
		emit_signal("advance")
	elif square.type == "Battle":
#		var level = (progress) as int
		var enemy = load("res://src/enemies/mimic" + ".tres")
		emit_signal("start_battle", enemy)
	elif square.type == "Chest":
		emit_signal("start_loot", 0)
	elif square.type == "Rest":
		square.clear()
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
