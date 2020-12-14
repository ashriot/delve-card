extends Node2D

static func execute(player: Player) -> void:
	player.apply_buff(preload("res://src/actions/buffs/mend.tres"), 4)
