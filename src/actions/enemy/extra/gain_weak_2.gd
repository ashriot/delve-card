extends Node2D

static func execute(player: Player) -> void:
	player.gain_debuff(preload("res://src/actions/debuffs/weak.tres"), 2)
	player.add_to_deck("fatigue", 2)
