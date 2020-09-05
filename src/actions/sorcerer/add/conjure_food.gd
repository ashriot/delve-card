extends Node2D


static func execute(player: Player) -> void:
	print("conjuring mana manna!")
	player.add_to_deck("mana_manna", 2)
