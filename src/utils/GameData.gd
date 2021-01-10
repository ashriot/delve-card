extends Resource
class_name GameData

export var game_version: String
export var profile_name: String

export(Array, Resource) var unlocked_jobs

export var current_hp: int
export var current_square: int
export var upgrade_cost: int
export var destroy_cost: int
export var merchants: Dictionary
export var dungeon: Dictionary
