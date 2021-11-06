extends Resource
class_name Gear

export var unlocked:= false
export var name: String
export(String, MULTILINE) var desc
export var level_req:= 1
export var cost: int
export var build:= false

export(Array, Resource) var trinkets
export(Array, Resource) var potions
