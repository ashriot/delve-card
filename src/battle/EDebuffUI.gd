extends Button
class_name EDebuffUI

signal remove_debuff(debuff)
signal show_card(debuff)
signal hide_card

var debuff

var debuff_name: String
var description: String setget, get_description
var stacks: int setget set_stacks
var fades_per_turn: bool

var hovering: = false

func initialize(_debuff: Buff, amt: int) -> void:
	debuff = _debuff
	debuff_name = debuff.name
	description = debuff.description
	description.replace("X", str(amt))
	self.stacks = amt
	fades_per_turn = debuff.fades_per_turn
	$Sprite.frame = debuff.frame_id

func set_stacks(value: int) -> void:
	stacks = value
	if stacks == 0:
		emit_signal("remove_debuff", debuff_name)
	else:
		$Stacks.text = str(stacks)
		$StacksShadow.text = str(stacks)

func get_description() -> String:
	description = debuff.description
	return description.replace("X", str(stacks))

func _on_Button_up() -> void:
	modulate.a = 1
	$Timer.stop()
	if hovering:
		hovering = false
		emit_signal("hide_card")
		return

func _on_Button_down():
	modulate.a = 0.66
	$Timer.start(.25)

func _on_Timer_timeout() -> void:
	$Timer.stop()
	hovering = true
	emit_signal("show_card", self)
