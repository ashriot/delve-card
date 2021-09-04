extends Node2D

static func execute(player: Player) -> void:
	player.gain_buff(preload("res://resources/actions/buffs/mist_shield.tres"), 1)
