extends Node2D

static func execute(player: Player) -> void:
	player.gain_debuff(preload("res://src/actions/debuffs/burn.tres"), 3)
