extends Control

signal start_battle

var enemy = preload("res://assets/images/map/monster.png")
var chest = preload("res://assets/images/map/chest_closed.png")
var heal = preload("res://assets/images/map/shrine.png")
var blank = preload("res://assets/images/map/tile_clear.png")

var row_count: = 5
var col_count: = 7

onready var square_types = ["Enemy", "Chest", "Heal", "Blank"]

func initialize() -> void:
	generate_map()

func generate_map() -> void:
	var enemies = randi() % 5 + 5
	var chests = randi() % 3 + 1
	var heals = randi() % 4 + 2
	print("Enemies: ", enemies)
	print("Chests: ", chests)
	print("Heals: ", heals)
	
	var squares = []
	squares.resize(row_count)
	for x in row_count:
		squares[x] = []
		squares[x].resize(col_count)
	
	while enemies > -1:
		enemies -= 1
		var x = randi() % row_count
		var y = randi() % col_count
		squares[x][y] = "Enemy"
	while chests > -1:
		chests -= 1
		var x = randi() % row_count
		var y = randi() % col_count
		squares[x][y] = "Chest"
	while heals > -1:
		heals -= 1
		var x = randi() % row_count
		var y = randi() % col_count
		squares[x][y] = "Heal"
	
	for x in get_children():
		for y in x.get_children():
			var val = squares[x.get_index()][y.get_index()]
			if val == "Enemy":
				y.initialize(enemy, val)
			elif val == "Chest":
				y.initialize(chest, val)
			elif val == "Heal":
				y.initialize(heal, val)
			else:
				y.initialize(blank, "Blank")
			y.connect("clicked", self, "square_clicked", [y])

func square_clicked(button: Square) -> void:
	if button.type == "Enemy":
		emit_signal("start_battle")
