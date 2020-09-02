extends Node2D


static func execute(player: Player) -> void:
	print("using Blood Sword!")
	player.hp += 3
