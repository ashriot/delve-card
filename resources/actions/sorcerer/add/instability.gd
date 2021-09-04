extends Node2D

static func execute(player: Player) -> void:
	player.gain_buff(preload("res://resources/actions/buffs/power.tres"), 5)
	player.gain_debuff(preload("res://resources/actions/debuffs/sunder.tres"), 1)
