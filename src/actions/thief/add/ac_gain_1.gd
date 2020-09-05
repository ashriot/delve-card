extends Node2D

static func execute(player: Player) -> void:
	print("gaining AC!")
	player.take_healing(1, "AC")
