extends Node2D

static func execute(player: Player, enemy: Enemy) -> void:
	player.gain_debuff(preload("res://resources/actions/debuffs/weak.tres"), 1)
