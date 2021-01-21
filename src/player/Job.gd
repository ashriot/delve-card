extends Resource
class_name Job

export var name: String
export var unlocked: = false
export(String, MULTILINE) var desc
export var sprite_id: int
export var max_hp: int
export var max_st: int
export var initial_ac: int
export var initial_mp: int
export var starting_gold: int
export var bonus_hp: int
export var bonus_mp: int
export var bonus_ac: int
export var bonus_st: int
export var bonus_gp: int
export var level: = 1
export var xp: int

export(Array, Resource) var perks

func clear_bonuses() -> void:
	bonus_hp = 0
	bonus_mp = 0
	bonus_ac = 0
	bonus_st = 0
	bonus_gp = 0

func hp() -> int:
	return max_hp + bonus_hp

func mp() -> int:
	return initial_mp + bonus_mp

func ac() -> int:
	return initial_ac + bonus_ac

func st() -> int:
	return max_st + bonus_st

func gold() -> int:
	return starting_gold + bonus_gp
