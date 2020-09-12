extends Node2D

var node_sprite = preload("res://assets/images/map/clear.png")
var enemy_sprite = preload("res://assets/images/map/enemy.png")
var chest_sprite = preload("res://assets/images/map/chest.png")
var heal_sprite = preload("res://assets/images/map/heal.png")
var shop_sprite = preload("res://assets/images/map/shop.png")
var anvil_sprite = preload("res://assets/images/map/anvil.png")
var shrine_sprite = preload("res://assets/images/map/shrine.png")
var branch_sprite = preload("res://assets/images/map/connector.png")
var up_sprite = preload("res://assets/images/map/stairs_up.png")
var down_sprite = preload("res://assets/images/map/stairs_down.png")

signal advance
signal move_to_square
signal start_battle
signal start_loot(gold)
signal heal
signal blacksmith

signal show_tooltip(button)
signal hide_tooltip

onready var branches = $Branches
onready var squares = $Squares

var generator: = preload("res://src/map/dungeon_generation.gd").new()
var _Square = preload("res://src/map/Square.tscn")
var astar: AStar2D

var DIST = 18
var max_x = 6
var max_y = 4

var dungeon = {}
var chest_max: = 3
var heal_max: = 3
var enemy_max: = 5
var shop_max: = 2
var anvil_max: = 1
var shrine_max: = 1

var parent: Dungeon

func initialize(dun: Dungeon) -> Square:
	parent = dun
	generate_dungeon()
	var origin = load_map()
	connect_squares()
	return origin

func generate_dungeon() -> void:
	astar = AStar2D.new()
	chest_max = randi() % 2 + 1
	heal_max = randi() % 3 + 1
	enemy_max = randi() % 2 + 2
	shop_max = 0
	anvil_max = 1
	shrine_max = 0
	var room_max = min(chest_max + heal_max + enemy_max + \
		shop_max + anvil_max + shrine_max + 6, 24)
	var room_min = room_max - 3
	dungeon = generator.generate(rand_range(-100, 100), [room_min, room_max])

func load_map() -> Square:
	var map = []
	var chests = chest_max
	var heals = heal_max
	var enemies = enemy_max
	var shops = shop_max
	var anvils = anvil_max
	var shrines = shrine_max
	
	var origin: Square

	for i in range(0, squares.get_child_count()):
		squares.get_child(i).queue_free()
	for i in range(0, branches.get_child_count()):
		branches.get_child(i).queue_free()
	
	for k in dungeon.keys():
		map.append([dungeon[k].connections, k])
		
	map.sort_custom(ActionSorter, "sort_vectors")
	var down_pos = map.back()[1]
	
	map.sort_custom(ActionSorter, "sort_ascending")
	
	for i in map:
		var square = dungeon.get(i[1])
		
		if i[1] == Vector2.ZERO:
			square.initialize(self, "Clear", node_sprite)
			origin = square
		else:
			if i[1] == down_pos:
				square.initialize(self, "Down", down_sprite)
			elif dungeon[i[1]].connections == 1:
				if chests > 0:
					chests -= 1
					square.initialize(self, "Chest", chest_sprite)
				elif shops > 0:
					shops -= 1
					square.initialize(self, "Shop", shop_sprite)
				elif anvils > 0:
					anvils -= 1
					square.initialize(self, "Anvil", anvil_sprite)
				elif shrines > 0:
					shrines -= 1
					square.initialize(self, "Shrine", shrine_sprite)
				else:
					heals -= 1
					square.initialize(self, "Rest", heal_sprite)
			else:
				if enemies > 0:
					enemies -= 1
					square.initialize(self, "Battle", enemy_sprite)
				elif chests > 0:
					chests -= 1
					square.initialize(self, "Chest", chest_sprite)
				elif shops > 0:
					shops -= 1
					square.initialize(self, "Shop", shop_sprite)
				elif anvils > 0:
					anvils -= 1
					square.initialize(self, "Anvil", anvil_sprite)
				elif shrines > 0:
					shrines -= 1
					square.initialize(self, "Shrine", shrine_sprite)
				elif heals > 0:
					heals -= 1
					square.initialize(self, "Rest", heal_sprite)
				else:
					square.initialize(self, "Clear", node_sprite)
		squares.add_child(square)
		square.rect_position = i[1] * DIST - Vector2(5, 5)
		astar.add_point(square.get_index(), square.rect_position)
		if square.type == "Battle":
			astar.set_point_disabled(square.get_index())
		var c_squares = dungeon.get(i[1]).connected_squares
		if(c_squares.get(Vector2(1, 0)) != null):
			var branch = Sprite.new()
			branch.texture = branch_sprite
			branches.add_child(branch)
			branch.position = i[1] * DIST + Vector2(10, 0.5)
		if(c_squares.get(Vector2(0, 1)) != null):
			var branch = Sprite.new()
			branch.texture = branch_sprite
			branches.add_child(branch)
			branch.rotation_degrees = 90
			branch.position = i[1] * DIST + Vector2(-0.5, 10)
	return origin

func connect_squares() -> void:
	for i in dungeon:
		var square = dungeon.get(i) as Square
		var conn = square.connected_squares
		for c in conn:
			var sq = conn.get(c)
			if sq != null:
				astar.connect_points(square.get_index(), sq.get_index())

func get_pos(index: int) -> Vector2:
	print(astar.get_point_position(index))
	return astar.get_point_position(index)

func square_clicked(button: Square) -> void:
	emit_signal("move_to_square", button)
	yield(parent, "done_pathing")
	if button.type == "Down":
		print("going down")
		generate_dungeon()
		emit_signal("advance")
	if button.type == "Battle":
		astar.set_point_disabled(button.get_index(), false)
		emit_signal("start_battle")
	elif button.type == "Chest":
		emit_signal("start_loot")
	elif button.type == "Rest":
		emit_signal("heal")
	elif button.type == "Anvil":
		emit_signal("blacksmith")
	if !button.cleared and button.type != "Anvil":
		button.clear()

func show_tooltip(button: Square) -> void:
	emit_signal("show_tooltip", button)

func hide_tooltip() -> void:
	emit_signal("hide_tooltip")

func _on_Button_pressed():
	generate_dungeon()
	load_map()
