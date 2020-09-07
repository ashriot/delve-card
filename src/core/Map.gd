extends Control

signal start_battle
signal start_loot
signal heal

signal show_tooltip(button)
signal hide_tooltip

var row_count: = 5
var col_count: = 7

func initialize() -> void:
	generate_map()

func generate_map() -> void:
	var enemies = randi() % 5 + 5
	var chests = randi() % 3 + 2
	var heals = randi() % 2 + 1
	var anvils = randi() % 2 + 1
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
		squares[x][y] = "enemy"
	while chests > -1:
		chests -= 1
		var x = randi() % row_count
		var y = randi() % col_count
		squares[x][y] = "chest"
	while heals > -1:
		heals -= 1
		var x = randi() % row_count
		var y = randi() % col_count
		squares[x][y] = "heal"
	while anvils > -1:
		anvils -= 1
		var x = randi() % row_count
		var y = randi() % col_count
		squares[x][y] = "anvil"
	
	for x in get_children():
		for y in x.get_children():
			var val = squares[x.get_index()][y.get_index()]
			if val == null:
				val = ""
			y.initialize(val)
			y.connect("clicked", self, "square_clicked", [y])
			y.connect("show_tooltip", self, "show_tooltip", [y])
			y.connect("hide_tooltip", self, "hide_tooltip")

func square_clicked(button: Square) -> void:
	print("Signal received: ", button.type)
	if button.type == "enemy":
		emit_signal("start_battle")
	elif button.type == "chest":
		emit_signal("start_loot")
	elif button.type == "heal":
		emit_signal("heal")

func show_tooltip(button: Square) -> void:
	emit_signal("show_tooltip", button)

func hide_tooltip() -> void:
	emit_signal("hide_tooltip")
