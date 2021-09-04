extends Node2D

static func execute(player: Player) -> void:
	player.take_healing(6, "MP")
