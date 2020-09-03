extends Node2D

static func execute(player: Player) -> void:
	print("gaining Lifesteal!")
	player.gain_buff(preload("res://src/actions/buffs/lifesteal.tres"), 1)
