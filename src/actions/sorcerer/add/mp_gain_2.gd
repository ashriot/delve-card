extends Node2D

static func execute(player: Player) -> void:
	print("gaining MP!")
	player.mp += 2
