extends Node2D

static func execute(player: Player) -> void:
	print("gaining Dodge 1!")
	player.gain_buff(preload("res://src/actions/buffs/dodge.tres"), 1)
