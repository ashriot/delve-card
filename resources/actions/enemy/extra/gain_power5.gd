extends Node2D

static func execute(player: Player, enemy: Enemy) -> void:
	enemy.gain_buff(preload("res://resources/actions/buffs/power.tres"), 5)
