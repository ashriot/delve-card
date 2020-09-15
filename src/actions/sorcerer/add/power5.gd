extends Node2D

static func execute(player: Player) -> void:
	player.gain_buff(preload("res://src/actions/buffs/power.tres"), 5)
