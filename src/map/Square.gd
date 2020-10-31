extends TextureButton
class_name Square

signal clicked
signal show_tooltip
signal hide_tooltip

onready var timer = $Timer

var type: String
var cleared: = false
var hovering: = false

var connected_squares = {
	Vector2.UP: null,
	Vector2.DOWN: null,
	Vector2.LEFT: null,
	Vector2.RIGHT: null
}

var connections: = 0
var initialized: = false

func initialize(map, _type: String, texture: Texture) -> void:
	if initialized: return
	cleared = false
	type = _type
	texture_normal = texture
	setup(map)
	initialized = true

func setup(map) -> void:
	connect("clicked", map, "square_clicked", [self])
	connect("show_tooltip", map, "show_tooltip", [self])
	connect("hide_tooltip", map, "hide_tooltip")

func clear() -> void:
	type = "Clear"
	texture_normal = load("res://assets/images/map/clear.png")
	cleared = true

func _on_Square_button_down():
	if cleared: return
	timer.start(0.33)
	modulate = Color.gray

func _on_Square_button_up():
	print("clicked!")
	timer.stop()
	modulate = Color.white
	if hovering:
		emit_signal("hide_tooltip")
		hovering = false
		return
	emit_signal("clicked")

func _on_Timer_timeout():
	timer.stop()
	emit_signal("show_tooltip")
	hovering = true
