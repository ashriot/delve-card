extends Node2D

static func execute(player: Player) -> void:
	player.apply_debuff(preload("res://src/actions/debuffs/sunder.tres"), 1)
