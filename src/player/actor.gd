extends Resource
class_name Actor

export var name: String
export var portrait_id: = 0
export var level: = 1
export var max_hp: = 1
export var max_ap: = 3
export var initial_ac: = 0
export var initial_mp: = 0
export var gold: = 0
export(Array, String) var active_traits

export var hp: int setget set_hp

export(Array) var trinkets: = []
export(Array) var potions: = []
export(Array) var actions: = []

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

func add_trait(name) -> void:
	active_traits.append(name)
	print("Gained trait: ", name)
	if name == "Iron Fortitude":
		max_hp += 6
		hp = max_hp
	if name == "Mana Flow": initial_mp += 3
	if name == "Loose Change": gold += 20
