extends Resource
class_name Actor

export var name: String
export var portrait_id: = 0
export var level: = 1
export var max_hp: = 1
export var max_ap: = 3
export var initial_ac: = 0
export var initial_mp: = 0
export var gold: = 0

var hp: int setget set_hp

export(Array) var potions: = []
export(Array) var actions: = []

func initialize() -> void:
	pass

func set_hp(value) -> void:
	hp = clamp(value, 0, max_hp)
