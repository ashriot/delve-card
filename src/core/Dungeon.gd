extends Node2D
class_name Dungeon

signal blank
signal advance
signal start_battle(enemy)
signal start_loot(gold)
signal heal
signal blacksmith
signal shop(square)
signal done_pathing

onready var floor_number = $ColorRect/TopBanner/FloorNum
onready var tooltip = $Tooltip
onready var tooltext = $Tooltip/PanelContainer/Label

onready var map = $Map
onready var avatar = $Avatar as Sprite
onready var avatar_tween = $Avatar/Tween
onready var colorRect = $ColorRect

var enemy_list: Array
var enemy_boss: String

var SAVE_KEY: String = "dungeon"
var current_square: int
var game_seed: String

var dungeon_name: String
var progress: int setget set_progress
var max_prog: int

var pathing: = false

func initialize(game) -> void:
	print("dungeon.initialize()")
	tooltip.hide()
	game_seed = game.game_seed
	enemy_list = ["slime", "devil"]
	enemy_boss = "bear"
	map.connect("move_to_square", self, "_on_Map_move_to_square", [], 2)
	map.connect("show_tooltip", self, "_on_Map_show_tooltip")
	map.connect("hide_tooltip", self, "_on_Map_hide_tooltip")

func new_map() -> void:
	print("dungeon.new_map()")
	map.initialize(self)
	var origin = map.get_origin()
	current_square = origin.get_index()

func reset() -> void:
	self.progress = 0
	reset_avatar()

func set_progress(value: int) -> void:
	progress = value
	floor_number.text = dungeon_name + " Lv. " + str(progress) + " of " + str(max_prog)

# Advance -> Stairs Down
func reset_avatar() -> void:
	self.progress += 1
	print("Progress: ", progress)
	if progress == 3:
		enemy_list.remove(0)
		enemy_list.append("Tiger")
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
	pathing = true
	current_square = to
	AudioController.steps()
	for p in path:
		avatar_tween.interpolate_property(avatar, "position",
			avatar.position,
			map.get_pos(p) - Vector2(3, 3) + map.position,
			0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		avatar_tween.start()
		yield(avatar_tween, "tween_all_completed")
	emit_signal("done_pathing")
	pathing = false
	return true

func _on_Map_move_to_square(square: Square):
	if pathing: return
	var moving = path(square)
	if not moving and (square.type != "Anvil" and square.type != "Shop" or square.get_index() != current_square):
		return
	if moving:
		yield(self, "done_pathing")
	if square.type == "Clear":
		emit_signal("blank")
	elif square.type == "Down":
		emit_signal("advance")
	elif square.type == "Battle":
		var enemy = load("res://src/enemies/" + square.enemy_name.to_lower() + ".tres")
		emit_signal("start_battle", enemy)
	elif square.type == "Chest":
		emit_signal("start_loot", 0)
	elif square.type == "Rest":
		square.clear()
		emit_signal("heal")
	elif square.type == "Anvil":
		emit_signal("blacksmith")
	elif square.type == "Shop":
		emit_signal("shop", current_square)
	if !square.cleared and square.type != "Anvil" and square.type != "Shop":
		square.clear()

func _on_Map_show_tooltip(button):
	if button.type == "Battle":
		var enemy = load("res://src/enemies/" + button.enemy_name.to_lower() + ".tres")
		tooltext.text = enemy.title
	else:
		tooltext.text = button.type.capitalize()
	var pos = get_global_mouse_position()
	var x = clamp(pos.x - tooltip.rect_size.x / 2, 0, 108 - tooltip.rect_size.x)
	var y = clamp(pos.y - tooltip.rect_size.y - 12, 0, 92 - tooltip.rect_size.y)
	tooltip.set_global_position(Vector2(x, y))
	tooltip.show()

func _on_Map_hide_tooltip():
	tooltip.hide()
