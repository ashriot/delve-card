extends Node2D

static func execute(player: Player, enemy: Enemy) -> void:
	enemy.gain_buff(preload("res://src/actions/buffs/power.tres"), 3)
