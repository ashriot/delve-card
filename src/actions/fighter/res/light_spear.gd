extends Node2D


static func execute(player: Player) -> void:
	print("using Light Spear!")
	player.take_healing(1, "ST")
