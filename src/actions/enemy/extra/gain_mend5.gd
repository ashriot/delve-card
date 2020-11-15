extends Node2D

static func execute(enemy: Enemy) -> void:
	enemy.gain_buff(preload("res://src/actions/buffs/mend.tres"), 5)
