extends Node2D

var dungeon = {}
var node_sprite = load("res://assets/images/map/clear.png")
var enemy_sprite = load("res://assets/images/map/enemy.png")
var chest_sprite = load("res://assets/images/map/chest.png")
var heal_sprite = load("res://assets/images/map/heal.png")
var branch_sprite = load("res://assets/images/map/connector.png")

var dungeon_generation: = preload("res://src/map/dungeon_generation.gd").new()

var DIST = 13

var chest_chance: = 1.0
var chest_falloff: = 0.5
var heal_chance: = 1.0
var heal_falloff: = 0.7
var heal_max: = 3
var enemy_chance: = 1.5
var enemy_falloff: = 0.7
var enemy_max: = 4

func _ready():
	dungeon = dungeon_generation.generate(0)
	load_map()

func load_map():
	var map = []
	var chest = chest_chance
	var heal = heal_chance
	var heals = heal_max
	var enemy = enemy_chance
	var enemies = enemy_max
	for i in range(0, get_child_count()):
		get_child(i).queue_free()
	
	for k in dungeon.keys():
		map.append([dungeon[k].connections, k])
	
	map.sort_custom(ActionSorter, "sort_ascending")
	
	for i in map:
		var temp = Sprite.new()
		if i[1] == Vector2.ZERO:
			temp.texture = node_sprite
		else:
			if dungeon[i[1]].connections == 1:
				if randf() < chest:
					chest *= chest_falloff
					temp.texture = chest_sprite
				else:
					heal *= heal_falloff
					heals -= 1
					temp.texture = heal_sprite
			else:
				if randf() < enemy and enemies > 0:
					enemy *= enemy_falloff
					enemies -= 1
					print("Enemy: ", enemy)
					temp.texture = enemy_sprite
				elif randf() < heal and heals > 0:
					heals -= 1
					heal *= heal_falloff
					temp.texture = heal_sprite
				else:
					temp.texture = node_sprite
		add_child(temp)
		temp.z_index = 1
		temp.position = i[1] * DIST
		var c_rooms = dungeon.get(i[1]).connected_rooms
		if(c_rooms.get(Vector2(1, 0)) != null):
			temp = Sprite.new()
			temp.texture = branch_sprite
			add_child(temp)
			temp.z_index = 0
			temp.position = i[1] * DIST + Vector2(5, 0.5)
		if(c_rooms.get(Vector2(0, 1)) != null):
			temp = Sprite.new()
			temp.texture = branch_sprite
			add_child(temp)
			temp.z_index = 0
			temp.rotation_degrees = 90
			temp.position = i[1] * DIST + Vector2(-0.5, 5)

func _on_Button_pressed():
	randomize()
	dungeon = dungeon_generation.generate(rand_range(-1000, 1000))
	load_map()
