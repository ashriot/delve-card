extends Resource
class_name Job

export var name: String
export var desc: String
export var sprite_id: int
export var max_hp: int
export var max_ap: int
export var initial_ac: int
export var initial_mp: int
export var starting_gold: int

export(Array, Resource) var perks
