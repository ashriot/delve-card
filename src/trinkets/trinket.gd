extends Resource
class_name Trinket

export var name: String
export(String, MULTILINE) var description setget , get_description
export var rarity: = 1
export var rank: = 0
export var frame_id: = 0

func get_description():
	return ["Equipment", description]
