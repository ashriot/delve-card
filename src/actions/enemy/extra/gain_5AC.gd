extends Node2D

static func execute(player: Player, enemy: Enemy) -> void:
	enemy.take_healing(5, Action.DamageType.AC)
