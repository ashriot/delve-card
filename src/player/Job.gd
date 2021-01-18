extends Resource
class_name Job

export var name: String
export(String, MULTILINE) var desc
export var sprite_id: int
export var max_hp: int
export var max_ap: int
export var initial_ac: int
export var initial_mp: int
export var starting_gold: int
export var level: = 1
export var xp: int

export(Array, Resource) var perks
