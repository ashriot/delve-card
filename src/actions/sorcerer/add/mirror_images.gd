extends Node2D


static func execute(player: Player) -> void:
	print("conjuring mirror images!")
	player.add_to_deck("mirror_image", 2)
