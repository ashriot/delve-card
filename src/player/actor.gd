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

export var bonus_hp: int
export var bonus_mp: int
export var bonus_ac: int
export var bonus_st: int
export var bonus_gp: int

export var total_hp: int setget, get_total_hp
export var st: int setget, get_st
export var mp: int setget, get_mp
export var ac: int setget, get_ac

export(Array, String) var active_traits
export(Array, Resource) var active_perks

export var hp: int setget set_hp

export(Array) var trinkets: = []
export(Array) var potions: = []
export(Array) var actions: = []

func initialize(job: Job) -> void:
	name = job.name
	portrait_id = job.sprite_id
	active_perks = job.perks
	trinkets = job.trinkets
	potions = job.potions
	actions = job.actions
	max_hp = job.hp()
	initial_mp = job.mp()
	initial_ac = job.ac()
	max_ap = job.st()
	gold = job.gold()
	hp = max_hp

func set_hp(value) -> void:
	hp = clamp(value, 0, max_hp)

func remove_action(action: Action) -> void:
	var index = actions.find(action)
	actions.remove(index)

func spend_gold(amt: int) -> void:
	gold -= amt

func have_enough_gold(amt: int) -> bool:
	return gold >= amt

func add_trait(trait: String) -> void:
	active_traits.append(trait)
	print("Gained trait: ", trait)
	if trait == "Iron Fortitude":
		max_hp += 6
		hp = max_hp
	if trait == "Mana Flow": initial_mp += 3
	if trait == "Pocket Change": gold += 20

func add_trinket(trinket: Trinket) -> void:
	print("Gained the ", trinket.name)
	trinkets.append(trinket)
	if trinket.name == "Magic Ring":
		initial_mp += trinket.rank * 2 + 2

func remove_trinket(trinket: Trinket) -> void:
	trinkets.remove(trinkets.find(trinket))
	if trinket.name == "Magic Ring":
		initial_mp -= trinket.rank * 2 + 2

func add_potion(potion: Action) -> void:
	potions.append(potion)

func set_build(build: Gear) -> void:
	if build.name == "Battlemage":
		max_ap += 1
		initial_ac += 2
		initial_mp -= 3

func clear_bonuses() -> void:
	bonus_hp = 0
	bonus_mp = 0
	bonus_ac = 0
	bonus_st = 0
	bonus_gp = 0

func update_perk_bonuses() -> void:
	for perk in active_perks:
		if perk.name == "Magic Armor" and perk.cur_ranks > 0:
			bonus_ac = ((self.mp) / ( 9 - (perk.amts[0] * perk.cur_ranks)))

func get_total_hp() -> int:
	return max_hp + bonus_hp

func get_ac() -> int:
	return initial_ac + bonus_ac

func get_st() -> int:
	return max_ap + bonus_st

func get_mp() -> int:
	return initial_mp + bonus_mp
