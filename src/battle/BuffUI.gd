extends Button
class_name BuffUI

signal remove_buff(buff)
signal show_card(buff)
signal hide_card

var buff

var buff_name: String
var description: String setget, get_description
var stacks: int setget set_stacks
var fades_per_turn: bool

var hovering: = false

func initialize(_buff: Buff, amt: int) -> void:
	buff = _buff
	buff_name = buff.name
	description = buff.description
	description.replace("X", str(amt))
	self.stacks = amt
	fades_per_turn = buff.fades_per_turn
	$Sprite.frame = buff.frame_id

func set_stacks(value: int) -> void:
	stacks = value
	if stacks == 0:
		emit_signal("remove_buff", buff_name)
	else:
		var text = str(stacks) if stacks > 1 else ""
		$Stacks.text = text
		$StacksShadow.text = text
		$StacksShadow2.text = text

func get_description() -> String:
	description = buff.description
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
