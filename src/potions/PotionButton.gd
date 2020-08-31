extends Control
class_name PotionButton

signal used_potion (potion)

onready var button: = $Button
onready var sprite: = $Button/Sprite

var action: Resource
var initialized: = false

func initialize(_action: Action) -> void:
	action = _action
	sprite.frame = action.frame_id
	initialized = true

func _on_Button_up():
	sprite.modulate.a = 1
	emit_signal("used_potion", action)

func _on_Button_button_down():
	sprite.modulate.a = 0.66
