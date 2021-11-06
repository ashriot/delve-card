extends Control
class_name TrinketButton


signal show_card(button)
signal hide_card
#signal used_potion(button)

onready var button:= $TextureButton
onready var sprite:= $TextureButton/Sprite
onready var timer:= $Timer

var player: PlayerUI
var trinket: Trinket
var hovering:= false
var initialized:= false

func initialize(_player: PlayerUI, _trinket: Trinket) -> void:
	player = _player
	trinket = _trinket
	sprite.frame = trinket.frame_id
	initialized = true
	connect("show_card", player, "show_card")
	connect("hide_card", player, "hide_card")

func _on_Button_up():
	sprite.modulate.a = 1
	timer.stop()
	if hovering:
		hovering = false
		emit_signal("hide_card")

func _on_Button_down():
	print("down")
	sprite.modulate.a = 0.66
	timer.start(.25)

func _on_Timer_timeout() -> void:
	timer.stop()
	hovering = true
	emit_signal("show_card", self, 0)
