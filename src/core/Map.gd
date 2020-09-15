extends Control

signal start_battle
signal start_loot(gold)
signal heal
signal blacksmith

signal show_tooltip(button)
signal hide_tooltip

var row_count: = 5
var col_count: = 7

func initialize() -> void:
	generate_map()

func generate_map() -> void:
	var enemies = randi() % 3 + 4
	var chests = randi() % 3 + 1
	var heals = randi() % 2 + 1
	var anvils = randi() % 2
	
	var squares = []
	squares.resize(row_count)
	for x in row_count:
		squares[x] = []
		squares[x].resize(col_count)
	
	while enemies > 0:
		enemies -= 1
		set_square(squares, "enemy")
	while chests > 0:
		chests -= 1
		set_square(squares, "chest")
	while heals > 0:
		heals -= 1
		set_square(squares, "heal")
	while anvils > 0:
		anvils -= 1
		set_square(squares, "anvil")
	
	for x in get_children():
		for y in x.get_children():
			var val = squares[x.get_index()][y.get_index()]
			if val == null:
				val = ""
			y.initialize(val)
			y.connect("clicked", self, "square_clicked", [y])
			y.connect("show_tooltip", self, "show_tooltip", [y])
			y.connect("hide_tooltip", self, "hide_tooltip")

func set_square(squares, square) -> void:
	var x = randi() % row_count
	var y = randi() % col_count
	while squares[x][y] != null:
		x = randi() % row_count
		y = randi() % col_count
	squares[x][y] = square

func square_clicked(button: Square) -> void:
	if button.type == "enemy":
		emit_signal("start_battle")
	elif button.type == "chest":
		emit_signal("start_loot", 0)
	elif button.type == "heal":
		emit_signal("heal")
	elif button.type == "blacksmith":
		emit_signal("blacksmith")

func show_tooltip(button: Square) -> void:
	emit_signal("show_tooltip", button)

func hide_tooltip() -> void:
	emit_signal("hide_tooltip")
