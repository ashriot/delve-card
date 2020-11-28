extends Node2D

static func execute(player: Player) -> void:
	player.gain_buff(preload("res://src/actions/buffs/stoneskin.tres"), 1)
	player.remove_debuff("Poison")
