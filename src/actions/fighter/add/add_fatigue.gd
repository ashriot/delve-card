extends Node2D

static func execute(player: Player) -> void:
	player.add_to_deck("fatigue", 1)
