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

onready var branches = $Branches
onready var rooms = $Rooms

var dungeon_generation: = preload("res://src/map/dungeon_generation.gd").new()

var DIST = 18

var dungeon = {}
var chest_max: = 3
var heal_max: = 3
var enemy_max: = 5
var shop_max: = 2
var anvil_max: = 1
var shrine_max: = 1

func _ready():
	randomize_maxes()
	dungeon = dungeon_generation.generate(0)
	load_map()

func randomize_maxes() -> void:
	chest_max = randi() % 2 + 1
	heal_max = randi() % 3 + 1
	enemy_max = randi() % 2 + 2
	shop_max = randi() % 2
	anvil_max = 0
	shrine_max = 0

func load_map():
	var map = []
	var chests = chest_max
	var heals = heal_max
	var enemies = enemy_max
	print("Enemies: ", enemies)
	var shops = shop_max
	print("Shops: ", shops)
	var anvils = anvil_max
	var shrines = shrine_max

	for i in range(0, rooms.get_child_count()):
		rooms.get_child(i).queue_free()
	for i in range(0, branches.get_child_count()):
		branches.get_child(i).queue_free()
	
	for k in dungeon.keys():
		map.append([dungeon[k].connections, k])
		
	map.sort_custom(ActionSorter, "sort_vectors")
	var down_pos = map.back()[1]
	
	print(down_pos)
	map.sort_custom(ActionSorter, "sort_ascending")
	
	for i in map:
		var temp = Sprite.new()
		if i[1] == Vector2.ZERO:
			temp.texture = up_sprite
		else:
			if i[1] == down_pos:
				temp.texture = down_sprite
			elif dungeon[i[1]].connections == 1:
				if chests > 0:
					chests -= 1
					temp.texture = chest_sprite
				elif shops > 0:
					shops -= 1
					temp.texture = shop_sprite
				elif anvils > 0:
					anvils -= 1
					temp.texture = anvil_sprite
				elif shrines > 0:
					shrines -= 1
					temp.texture = shrine_sprite
				else:
					heals -= 1
					temp.texture = heal_sprite
			else:
				if enemies > 0:
					enemies -= 1
					temp.texture = enemy_sprite
				elif chests > 0:
					chests -= 1
					temp.texture = chest_sprite
				elif shops > 0:
					shops -= 1
					temp.texture = shop_sprite
				elif anvils > 0:
					anvils -= 1
					temp.texture = anvil_sprite
				elif shrines > 0:
					shrines -= 1
					temp.texture = shrine_sprite
				elif heals > 0:
					heals -= 1
					temp.texture = heal_sprite
				else:
					temp.texture = node_sprite
		rooms.add_child(temp)
		temp.position = i[1] * DIST
		var c_rooms = dungeon.get(i[1]).connected_rooms
		if(c_rooms.get(Vector2(1, 0)) != null):
			temp = Sprite.new()
			temp.texture = branch_sprite
			branches.add_child(temp)
			temp.z_index = 0
			temp.position = i[1] * DIST + Vector2(10, 0.5)
		if(c_rooms.get(Vector2(0, 1)) != null):
			temp = Sprite.new()
			temp.texture = branch_sprite
			branches.add_child(temp)
			temp.rotation_degrees = 90
			temp.position = i[1] * DIST + Vector2(-0.5, 10)

func _on_Button_pressed():
	randomize_maxes()
	dungeon = dungeon_generation.generate(rand_range(-1000, 1000))
	load_map()
