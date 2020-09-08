extends TextureButton
class_name Square

signal clicked
signal show_tooltip
signal hide_tooltip

onready var timer = $Timer

var type: String
var clicked: = false
var hovering: = false

var connected_rooms = {
	Vector2.UP: null,
	Vector2.DOWN: null,
	Vector2.LEFT: null,
	Vector2.RIGHT: null
}

var connections: = 0

func initialize(_type: String) -> void:
	type = _type
	texture_normal = load("res://assets/images/map/" + type + ".png")
	clicked = false

func _on_Square_button_down():
	timer.start(0.33)
	if clicked: return
	modulate = Color.gray

func _on_Square_button_up():
	timer.stop()
	modulate = Color.white
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
