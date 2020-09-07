extends TextureButton
class_name Square

signal clicked
signal show_tooltip
signal hide_tooltip

onready var timer = $Timer

var type: String
var clicked: = false
var hovering: = false

func initialize(_type: String) -> void:
	type = _type
	if type == "":
		clicked = true
		modulate.a = 0
	else:
		texture_normal = load("res://assets/images/map/" + type + ".png")
		clicked = false
		modulate.a = 1

func _on_Square_button_down():
	timer.start(0.33)
	if clicked: return
	modulate.a = 0.66

func _on_Square_button_up():
	timer.stop()
	modulate.a = 1
	if hovering:
		emit_signal("hide_tooltip")
		hovering = false
		return
	if clicked: return
	AudioController.click()
	clicked = true
	texture_normal = load("res://assets/images/map/clear.png")
	emit_signal("clicked")

func _on_Timer_timeout():
	timer.stop()
	emit_signal("show_tooltip")
	hovering = true
