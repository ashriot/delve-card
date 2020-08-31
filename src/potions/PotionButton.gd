extends Control
class_name PotionButton

signal show_card(potion_button)
signal hide_card
signal used_potion (potion)

onready var button: = $Button
onready var sprite: = $Button/Sprite
onready var timer: = $Timer

var action: Resource
var hovering: = false
var initialized: = false

func initialize(_action: Action) -> void:
	action = _action
	sprite.frame = action.frame_id
	initialized = true

func _on_Button_up():
	sprite.modulate.a = 1
	timer.stop()
	if hovering:
		hovering = false
		emit_signal("hide_card")
	else:
		emit_signal("used_potion", action)

func _on_Button_button_down():
	sprite.modulate.a = 0.66
	timer.start(.25)

func _on_Timer_timeout() -> void:
	timer.stop()
	hovering = true
	emit_signal("show_card", self)
	
