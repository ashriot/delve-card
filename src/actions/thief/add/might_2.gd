extends Node2D

static func execute(player: Player) -> void:
	print("gaining Might 2!")
	player.gain_buff(preload("res://src/actions/buffs/might.tres"), 2)
