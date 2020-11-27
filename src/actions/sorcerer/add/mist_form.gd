extends Node2D

static func execute(player: Player) -> void:
	player.gain_buff(preload("res://src/actions/buffs/mist_form.tres"), 1)
	player.remove_debuff("Burn")
