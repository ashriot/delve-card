extends Node2D

var node_sprite = load("res://assets/images/map/clear.png")
var enemy_sprite = load("res://assets/images/map/enemy.png")
var chest_sprite = load("res://assets/images/map/chest.png")
var heal_sprite = load("res://assets/images/map/heal.png")
var shop_sprite = load("res://assets/images/map/shop.png")
var anvil_sprite = load("res://assets/images/map/anvil.png")
var shrine_sprite = load("res://assets/images/map/shrine.png")
var branch_sprite = load("res://assets/images/map/connector.png")
var up_sprite = load("res://assets/images/map/stairs_up.png")
var down_sprite = load("res://assets/images/map/stairs_down.png")

signal advance
signal move_to_square
signal start_battle
signal start_loot
signal heal

signal show_tooltip(button)
signal hide_tooltip

onready var branches = $Branches
onready var squares = $Squares

var dungeon_generation: = preload("res://src/map/dungeon_generation.gd").new()
var _Square = preload("res://src/map/Square.tscn")

var DIST = 18

var dungeon = {}
var chest_max: = 3
var heal_max: = 3
var enemy_max: = 5
var shop_max: = 2
var anvil_max: = 1
var shrine_max: = 1

func initialize():
	generate_dungeon()
	load_map()

func generate_dungeon() -> void:
	chest_max = randi() % 2 + 1
	heal_max = randi() % 3 + 1
	enemy_max = randi() % 2 + 2
	shop_max = 0
	anvil_max = 0
	shrine_max = 0
	var room_max = min(chest_max + heal_max + enemy_max + \
		shop_max + anvil_max + shrine_max + 6, 24)
	var room_min = room_max - 3
	dungeon = dungeon_generation.generate(rand_range(-100, 100), [room_min, room_max])	

func load_map():
	var map = []
	var chests = chest_max
	var heals = heal_max
	var enemies = enemy_max
	var shops = shop_max
	var anvils = anvil_max
	var shrines = shrine_max

	for i in range(0, squares.get_child_count()):
		squares.get_child(i).queue_free()
	for i in range(0, branches.get_child_count()):
		branches.get_child(i).queue_free()
	
	for k in dungeon.keys():
		map.append([dungeon[k].connections, k])
		
	map.sort_custom(ActionSorter, "sort_vectors")
	var down_pos = map.back()[1]
	
	print(down_pos)
	map.sort_custom(ActionSorter, "sort_ascending")
	
	for i in map:
		var square = _Square.instance() as Square
		if i[1] == Vector2.ZERO:
			square.initialize(self, "Clear", node_sprite)
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

func square_clicked(button: Square) -> void:
	print("Signal received: ", button.type)
	emit_signal("move_to_square", button)
	if button.type == "Down":
		print("going down")
		generate_dungeon()
		emit_signal("advance")
	if button.type == "Battle":
		emit_signal("start_battle")
	elif button.type == "Chest":
		emit_signal("start_loot")
	elif button.type == "Rest":
		emit_signal("heal")

func show_tooltip(button: Square) -> void:
	emit_signal("show_tooltip", button)

func hide_tooltip() -> void:
	emit_signal("hide_tooltip")

func _on_Button_pressed():
	generate_dungeon()
	load_map()
