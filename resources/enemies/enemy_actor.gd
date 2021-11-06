extends Resource
class_name EnemyActor

export var name: String
export var title: String
export(String, MULTILINE) var desc
export var level := 1
export var max_hp := 1
export var max_ap := 3
export var initial_ac := 0
export var initial_mp := 0
export var attack_power := 5
export var gold := 0
export var texture: Texture

var hp: int setget set_hp

export(Array) var actions := []

func initialize() -> void:
	pass

func set_hp(value) -> void:
	hp = clamp(value, 0, max_hp)

func remove_action(action: Action) -> void:
	var index = actions.find(action)
	actions.remove(index)

func spend_gold(amt: int) -> void:
	gold -= amt

func have_enough_gold(amt: int) -> bool:
	return gold >= amt

func get_desc() -> String:
	return title + "\nMax HP: " + str(max_hp) + "\n" + desc
