extends Node2D

static func execute(player: Player) -> void:
	player.take_healing(3, "HP")
