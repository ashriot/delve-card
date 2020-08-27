extends Resource
class_name Action

enum ActionType {
	MELEE,
	RANGED,
	SPELL,
	FEAT,
	PASSIVE,
	CURSE,
	ITEM
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
export(ActionType) var action_type: = ActionType.MELEE
export(TargetType) var target_type: = TargetType.OPPONENT
export var ap_cost: = 0
export var mp_cost: = 0
export var healing: = false
export(DamageType) var damage_type: = DamageType.HP
export var damage: = 0
export var hits: = 1
export var drawX: = 0
export var frame_id: = 0
export var fx: PackedScene

func get_description() -> String:
	var text: String
	text = (ActionType.keys()	[action_type] as String).capitalize()
	text += ". " + description.replace("%dmg", str(damage))
	return text
