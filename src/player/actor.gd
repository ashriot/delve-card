extends Resource
class_name Actor

export var name: String
export var level: = 1
export var max_hp: = 1
export var max_ap: = 3
export var initial_ac: = 0
export var initial_mp: = 0
export var gold: = 0

var hp: int

export(Array) var potions: = []
export(Array) var actions: = []

func initialize() -> void:
	pass
