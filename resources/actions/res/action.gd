extends Resource
class_name Action

enum ActionType {
	WEAPON,
	SPELL,
	CRYSTAL,
	SKILL,
	PERMANENT,
	INJURY,
	ITEM,
	ANY
}

enum TargetType {
	MYSELF,
	OPPONENT,
	BOTH
}

enum DamageType {
	HP,
	AC,
	MP,
	AP
}

export var name: String
export(String, MULTILINE) var description setget, get_description
export var rarity: = 1
export var upgraded: = false
export(ActionType) var action_type: = ActionType.WEAPON
export(TargetType) var target_type: = TargetType.OPPONENT
export(DamageType) var cost_type: = DamageType.AP
export var cost: = 0
export var healing: = false
export(DamageType) var damage_type: = DamageType.HP
export var damage: = 0
export var hits: = 1
export var crit_chance: = 0.0
export var penetrate: = false
export var impact: = 0
export var drawX: = 0
export var discard_random_x: = 0
export var discard_x: = 0
export(ActionType) var draw_type: = ActionType.ANY
export var undodgeable: bool
export var first_strike: bool
export var drop: = false
export var fade: = false
export var consume: = false
export var frame_id: = 0
export var fx: PackedScene
export var extra_action: Resource
export (Array, Array)var gain_buffs
export (Array, Array)var gain_debuffs
export (Array, Array)var inflict_debuffs
export (Array, Array)var inflict_buffs

func execute() -> void:
	pass

func get_description() -> Array:
	var dmg = str(damage) + ("x" + str(hits) if hits > 1 else "")
	var text = description.replace("%damage", dmg)
	var dmg2 = str(damage * 2) + ("x" + str(hits) if hits > 1 else "")
	var dmg3 = str(damage * 3) + ("x" + str(hits) if hits > 1 else "")
	text = text.replace("%dx2", dmg2)
	text = text.replace("%dx3", dmg3)
	text = text.replace("%drawX", str(drawX))
	if crit_chance > 0:
		text += " " + str(crit_chance* 100) + "% Crit chance."
	if impact > 0:
		text += " Impact x" + str(impact) + "."
	if penetrate:
		text += " Penetrate."
	if drop:
		text += " Drop."
	if fade:
		text += " Fade."
	if consume:
		text += " Consume."
	var type = (ActionType.keys()[action_type] as String).capitalize()
	return [type, text]
