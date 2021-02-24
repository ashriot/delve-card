extends Resource
class_name Trinket

export var name: String
export(String, MULTILINE) var description setget , get_description
export var rarity: = 1
export var rank: = 0
export var frame_id: = 0
export var battle_start: = false
export var battle_end: = false
export var turn_start: = false
export var turn_end: = false

func get_description():
	return ["Equipment", description]
