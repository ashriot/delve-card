extends Node2D

var node_sprite = preload("res://assets/images/map/clear.png")
var enemy_sprite = preload("res://assets/images/map/enemy.png")
var boss_sprite = preload("res://assets/images/map/boss.png")
var chest_sprite = preload("res://assets/images/map/chest.png")
var heal_sprite = preload("res://assets/images/map/heal.png")
var event_sprite = preload("res://assets/images/map/event.png")
var shop_sprite = preload("res://assets/images/map/shop.png")
var anvil_sprite = preload("res://assets/images/map/anvil.png")
var shrine_sprite = preload("res://assets/images/map/shrine.png")
var branch_sprite = preload("res://assets/images/map/connector.png")
var up_sprite = preload("res://assets/images/map/stairs_up.png")
var down_sprite = preload("res://assets/images/map/stairs_down.png")

signal move_to_square
signal show_tooltip(button)
signal hide_tooltip

onready var branches = $Branches
onready var squares = $Squares

var generator: = preload("res://src/map/dungeon_generation.gd").new()
var _Square = preload("res://src/map/Square.tscn")
var astar: AStar2D
var origin: Square
var exit: Square
var enemy_list: Array
var enemy_boss: String
var progress: int
var max_prog: int

var DIST = 18

var dungeon = {}
var chest_max: = 3
var heal_max: = 3
var event_max: = 3
var enemy_max: = 5
var shop_max: = 2
var anvil_max: = 1
var shrine_max: = 1

func initialize(_dungeon: Dungeon) -> void:
	enemy_list = _dungeon.enemy_list
	enemy_boss = _dungeon.enemy_boss
	progress = _dungeon.progress
	max_prog = _dungeon.max_prog
# warning-ignore:integer_division
	chest_max = max(progress / 2, 1)
# warning-ignore:integer_division
	heal_max = randi() % 2 + max(progress / 2, 0) + 1
# warning-ignore:integer_division
	event_max = randi() % int(max(progress / 2 + 1, 0)) + 1 if progress > 1 else 0
# warning-ignore:integer_division
	enemy_max = 3 + int(progress / 2)
# warning-ignore:integer_division
	shop_max = randi() % int(max(progress / 2, 1)) + 1
	anvil_max = 1
	shrine_max = 0
	branches = $Branches
	branches.set_owner(self)
	squares.set_owner(self)
	generation_loop()
	while astar.get_id_path(origin.get_index(), exit.get_index()).size() > 1:
		print("looping!")
		clear_map()
		generation_loop()
	for child in branches.get_children():
		child.set_owner(self)
	for child in squares.get_children():
		child.set_owner(self)

func generation_loop() -> void:
	generate_dungeon()
	load_map()
	add_squares_to_astar()
	connect_squares()

func get_origin() -> Square:
	if origin == null:
		for child in squares.get_children():
			if child.origin:
				origin = child
	return origin as Square

func generate_dungeon() -> void:
	var room_max = min(chest_max + heal_max + event_max + enemy_max + \
		shop_max + anvil_max + shrine_max + 2, 36)
	generator.generate([room_max, room_max])
	dungeon = generator.get_dungeon()

func clear_map() -> void:
	for child in squares.get_children():
		child.free()
	for child in branches.get_children():
		child.free()

func load_map() -> void:
	var map = []
	var chests = chest_max
	var heals = heal_max
	var events = event_max
	var enemies = enemy_max
	var shops = shop_max
	var anvils = anvil_max
	var shrines = shrine_max

	for k in dungeon.keys():
		map.append([dungeon[k].connections, k])

	map.sort_custom(ActionSorter, "sort_vectors")
	var down_pos = map.back()[1]

	map.sort_custom(ActionSorter, "sort_ascending")

	for i in map:
		var square = dungeon.get(i[1])
		if i[1] == Vector2.ZERO:
			square.initialize("Clear", node_sprite)
			origin = square
			square.origin = true
		else:
			if i[1] == down_pos:
				if progress == max_prog:
					var enemy_name = enemy_boss
					square.initialize("Battle", boss_sprite, enemy_name)
				else:
					square.initialize("Down", down_sprite)
				exit = square
			elif dungeon[i[1]].connections == 1:
				if chests > 0:
					chests -= 1
					square.initialize("Chest", chest_sprite)
				elif shops > 0:
					shops -= 1
					square.initialize("Shop", shop_sprite)
				elif anvils > 0:
					anvils -= 1
					square.initialize("Anvil", anvil_sprite)
				elif shrines > 0:
					shrines -= 1
					square.initialize("Shrine", shrine_sprite)
				elif events > 0:
					events -= 1
					square.initialize("Event", event_sprite)
				else:
					heals -= 1
					square.initialize("Rest", heal_sprite)
			else:
				if enemies > 0:
					enemies -= 1
					var enemy_name = enemy_list[randi() % enemy_list.size()]
					square.initialize("Battle", enemy_sprite, enemy_name)
				elif chests > 0:
					chests -= 1
					square.initialize("Chest", chest_sprite)
				elif shops > 0:
					shops -= 1
					square.initialize("Shop", shop_sprite)
				elif anvils > 0:
					anvils -= 1
					square.initialize("Anvil", anvil_sprite)
				elif shrines > 0:
					shrines -= 1
					square.initialize("Shrine", shrine_sprite)
				elif events > 0:
					events -= 1
					square.initialize("Event", event_sprite)
				elif heals > 0:
					heals -= 1
					square.initialize("Rest", heal_sprite)
				else:
					square.initialize("Clear", node_sprite)
		squares.add_child(square)
		square.rect_position = i[1] * DIST - Vector2(5, 5)
		if(dungeon.get(i[1]).get_dir(Vector2(1, 0)) != Vector2.ZERO):
			var branch = Sprite.new()
			branch.texture = branch_sprite
			branches.add_child(branch)
			branch.position = i[1] * DIST + Vector2(10, 1)
		if(dungeon.get(i[1]).get_dir(Vector2(0, 1)) != Vector2.ZERO):
			var branch = Sprite.new()
			branch.texture = branch_sprite
			branches.add_child(branch)
			branch.rotation_degrees = 90
			branch.position = i[1] * DIST + Vector2(0, 10)

func add_squares_to_astar() -> void:
	astar = AStar2D.new()
	squares = $Squares
	for square in squares.get_children():
		astar.add_point(square.get_index(), square.rect_position)
		if square.type == "Battle": astar.set_point_disabled(square.get_index())

func connect_squares() -> void:
	for square in squares.get_children():
		square.setup(self)
		if square.up != Vector2.ZERO:
			astar.connect_points(square.get_index(), get_index_by_pos(square.up))
		if square.down != Vector2.ZERO:
			astar.connect_points(square.get_index(), get_index_by_pos(square.down))
		if square.left != Vector2.ZERO:
			astar.connect_points(square.get_index(), get_index_by_pos(square.left))
		if square.right != Vector2.ZERO:
			astar.connect_points(square.get_index(), get_index_by_pos(square.right))

func get_pos(index: int) -> Vector2:
	return astar.get_point_position(index)

func get_index_by_pos(pos) -> int:
	for child in squares.get_children():
		if child.pos == pos:
			return child.get_index()
	return -1

func square_clicked(button: Square) -> void:
	if button.type == "Battle":
		var index = button.get_index()
		astar.set_point_disabled(index, false)
	emit_signal("move_to_square", button)

func show_tooltip(button: Square) -> void:
	emit_signal("show_tooltip", button)

func hide_tooltip() -> void:
	emit_signal("hide_tooltip")
