extends Control
class_name ActionChoice

signal show_card(action_button)
signal hide_card
signal chosen(action)

onready var timer = $Timer

var action: Action
var player: Actor

var ap_cost: int
var mp_cost: int
var hp_cost: int
var damage: int
var hits: int
var chosen: bool setget set_chosen

var hovering: = false
var initialized: = false

func initialize(_action: Action, _player: Actor) -> void:
	if _action == null:
		print ("Action is null!")
		return
	self.chosen = false
	action = _action
	player = _player
	var rarity = ""
	for _i in range(action.rarity):
		rarity += "*"
	$Button/Rarity.text = rarity
	$Button/AP.hide()
	$Button/MP.hide()
	$Button/Sprite.frame = action.frame_id
	$Button/Chosen/HighlightSprite.frame = action.frame_id
	$Button.text = action.name
	$Button/Chosen/HighlightText.text = action.name
	$Button/Chosen.hide()
	if action.cost_type == Action.DamageType.HP:
		hp_cost = action.cost
	elif action.cost_type == Action.DamageType.MP:
		mp_cost = action.cost
	if action.cost_type == Action.DamageType.AP:
		ap_cost = action.cost
	damage = action.damage
	hits = action.hits
	update_data()
	initialized = true

func update_data() -> void:
	if action.cost_type == Action.DamageType.AP and action.cost > 0:
		$Button/AP.rect_size = Vector2(5 * ap_cost, 7)
		$Button/AP.show()
	elif action.cost_type == Action.DamageType.MP and action.cost > 0:
		$Button/MP.bbcode_text = " " + str(mp_cost) + "MP"
		$Button/MP.show()
	elif action.cost_type == Action.DamageType.HP and action.cost > 0:
		$Button/MP.bbcode_text = " -" + str(hp_cost) + "HP"
		$Button/MP.show()
	
	var hit_text = "" if hits < 2 else ("x" + str(hits))
	var type = ""
	if action.action_type == Action.ActionType.PERMANENT:
		type = " max"
	if action.damage_type == Action.DamageType.HP:
		type += "HP" if action.healing else "dmg"
	if action.damage_type == Action.DamageType.AC:
		type = "AC"
	elif action.damage_type == Action.DamageType.MP:
		type += "MP"
	elif action.damage_type == Action.DamageType.AP:
		type = "ST"
	var prepend = "+" if action.healing else ""
	var text = "[right]" + prepend + str(damage) + hit_text + type
	if action.name == "Brilliant Crystal":
		text = "[right]+2xMP"
	if action.damage == 0:
		text = ""
	$Button/Damage.bbcode_text = text

func _on_Button_up() -> void:
	timer.stop()
	if hovering:
		hovering = false
		emit_signal("hide_card")
		return
	else:
		emit_signal("chosen", self)

func _on_Button_down():
	timer.start(.25)

func _on_Timer_timeout():
	timer.stop()
	hovering = true
	emit_signal("show_card", self)

func set_chosen(value: bool) -> void:
	chosen = value
	if chosen:
		$Button/Chosen.show()
	else:
		$Button/Chosen.hide()
