extends Node2D


static func execute(player: Player) -> void:
	print("conjuring mana blades!")
	player.add_to_deck("manablade", 2)
