extends Resource
class_name Perk

export var name: String
export(String, MULTILINE) var desc
export var trait:= false
export(Array, String) var units
export(Array, int) var amts
export var cost:= 0
export var cur_ranks:= 0
export var max_ranks:= 1
export var tier:= 0
export var level_req:= 1
