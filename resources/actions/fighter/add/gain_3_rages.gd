extends Node2D

static func execute(player: Player) -> void:
	var rages = ["battle", "blood", "deadly", "endless", "power"]
	var actions = []
	for i in range(3):
		var rage = rages[randi() % 5]
		print("getting ", rage, " rage!")
		actions.append(rage + "_rage")
	player.add_many_to_deck(actions)
