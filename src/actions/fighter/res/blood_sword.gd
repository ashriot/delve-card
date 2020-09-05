extends Node2D


static func execute(player: Player) -> void:
	print("using Blood Sword!")
	player.take_healing(3, "HP")
