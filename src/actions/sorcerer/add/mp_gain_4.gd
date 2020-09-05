extends Node2D

static func execute(player: Player) -> void:
	print("gaining MP!")
	player.take_healing(4, "MP")
