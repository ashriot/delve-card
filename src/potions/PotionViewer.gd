extends Control
class_name PotionViewer


signal show_card(button)
signal hide_card
signal used_potion(button)

onready var button: = $Button
onready var sprite: = $Button/Sprite
onready var timer: = $Timer

var action: Resource
var player: Player
var hovering: = false
var initialized: = false

func initialize(player: PlayerUI, _action: Action) -> void:
	action = _action
	sprite.frame = action.frame_id
	initialized = true
	connect("show_card", player, "show_card")
	connect("hide_card", player, "hide_card")

func _on_Button_up():
	sprite.modulate.a = 1
	timer.stop()
	if hovering:
		hovering = false
		emit_signal("hide_card")

func _on_Button_button_down():
	sprite.modulate.a = 0.66
	timer.start(.25)

func _on_Timer_timeout() -> void:
	timer.stop()
	hovering = true
	emit_signal("show_card", self, 0)
