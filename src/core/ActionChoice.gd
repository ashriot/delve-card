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
var damage: int
var hits: int
var chosen: bool setget set_chosen

var hovering: = false
var initialized: = false

func initialize(_action: Action, _player: Actor) -> void:
	self.chosen = false
	action = _action
	player = _player
	$Button/AP.hide()
	$Button/MP.hide()
	$Button/Sprite.frame = action.frame_id
	$Button/Chosen/HighlightSprite.frame = action.frame_id
	$Button.text = action.name
	$Button/Chosen/HighlightText.text = action.name
	$Button/Chosen.hide()
	ap_cost = action.ap_cost
	mp_cost = action.mp_cost
	damage = action.damage
	hits = action.hits
	update_data()
	initialized = true

func update_data() -> void:
	if action.ap_cost > 0:
		$Button/AP.rect_size = Vector2(5 * action.ap_cost, 7)
		$Button/AP.show()
	elif action.mp_cost > 0:
		$Button/MP.bbcode_text = " " + str(action.mp_cost) + "MP"
		$Button/MP.show()
	
	var hit_text = "" if hits < 2 else ("x" + str(hits))
	var type = "HP" if action.healing else "dmg"
	if action.damage_type == Action.DamageType.AC:
		type = "AC"
	elif action.damage_type == Action.DamageType.MP:
		type = "MP"
	elif action.damage_type == Action.DamageType.AP:
		type = "AP"
	var prepend = "+" if action.healing else ""
	var text = "[right]" + prepend + str(damage) + hit_text + type
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
