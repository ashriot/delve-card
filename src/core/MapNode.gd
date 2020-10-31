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

signal move_to_square
signal show_tooltip(button)
signal hide_tooltip

onready var branches = $Branches
onready var squares = $Squares

var generator: = preload("res://src/map/dungeon_generation.gd").new()
var _Square = preload("res://src/map/Square.tscn")
var astar: AStar2D
var origin = null

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

var SAVE_KEY: String = "map"

func initialize() -> void:
	dungeon = {}
	chest_max = randi() % 2 + 1
	heal_max = randi() % 3 + 1
	enemy_max = randi() % 2 + 2
	shop_max = 0
	anvil_max = 1
	shrine_max = 0
	generate_dungeon()
	load_map()
	connect_squares()

func get_origin() -> Square:
	return origin as Square

func generate_dungeon() -> void:
	astar = AStar2D.new()
	var room_max = min(chest_max + heal_max + enemy_max + \
		shop_max + anvil_max + shrine_max + 6, 24)
	var room_min = room_max - 3
	dungeon = generator.generate([room_min, room_max])

func clear_map() -> void:
	for child in squares.get_children():
		child.queue_free()
	for child in branches.get_children():
		child.queue_free()

func load_map() -> void:
	var map = []
	var chests = chest_max
	var heals = heal_max
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

func connect_squares() -> void:
	for i in dungeon:
		var square = dungeon.get(i) as Square
		var conn = square.connected_squares
		for c in conn:
			var sq = conn.get(c)
			if sq != null:
				astar.connect_points(square.get_index(), sq.get_index())

func get_pos(index: int) -> Vector2:
	return astar.get_point_position(index)

func square_clicked(button: Square) -> void:
	if button.type == "Battle":
		astar.set_point_disabled(button.get_index(), false)
	emit_signal("move_to_square", button)

func show_tooltip(button: Square) -> void:
	emit_signal("show_tooltip", button)

func hide_tooltip() -> void:
	emit_signal("hide_tooltip")

func save(save_game: Resource) -> void:
	print("saving " + SAVE_KEY + " data")
	save_game.data[SAVE_KEY] = {
		"dungeon": dungeon
	}

func load(save_game: Resource):
	print("load map")
	var data: Dictionary = save_game.data[SAVE_KEY]
	dungeon = data["dungeon"]
	var origin = load_map()
	connect_squares()
	return origin

func _on_Button_pressed():
	generate_dungeon()
	load_map()
