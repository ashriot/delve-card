extends Node2D

static func execute(player: Player) -> void:
	player.apply_debuff(preload("res://resources/actions/debuffs/poison.tres"), 1)
