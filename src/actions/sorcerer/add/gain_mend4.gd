extends Node2D

static func execute(player: Player) -> void:
	print("GAIN MEND 4")
	player.gain_buff(preload("res://src/actions/buffs/mend.tres"), 4)
