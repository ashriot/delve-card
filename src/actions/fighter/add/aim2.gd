extends Node2D

static func execute(player: Player) -> void:
	print("gain aim 2")
	player.gain_buff(preload("res://src/actions/buffs/aim.tres"), 2)
