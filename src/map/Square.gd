extends TextureButton
class_name Square

signal clicked
signal show_tooltip
signal hide_tooltip

onready var timer = $Timer

export var pos: Vector2
export var origin: = false

export var type: String
export var enemy_name: String
export var cleared: = false
export var hovering: = false

export var up: = Vector2.ZERO
export var down: = Vector2.ZERO
export var left: = Vector2.ZERO
export var right: = Vector2.ZERO
export var connected: = false
export var initialized: = false

var connections: = 0 setget, get_connections

func initialize(_type: String, texture: Texture, _enemy_name: = "") -> void:
	if initialized: return
	type = _type
	enemy_name = _enemy_name
	cleared = true if type == "Clear" else false
	texture_normal = texture
	connect("button_down", self, "_on_Square_button_down", [], 2)
	connect("button_up", self, "_on_Square_button_up", [], 2)
	initialized = true

func setup(map) -> void:
	connect("clicked", map, "square_clicked", [self], 8)
	connect("show_tooltip", map, "show_tooltip", [self], 8)
	connect("hide_tooltip", map, "hide_tooltip", [], 8)
	connected = true

func clear() -> void:
	type = "Clear"
	texture_normal = load("res://assets/images/map/clear.png")
	cleared = true

func _on_Square_button_down():
	modulate = Color.gray
	timer.start(0.33)

func _on_Square_button_up():
	timer.stop()
	modulate = Color.white
	if hovering:
		if cleared: return
		emit_signal("hide_tooltip")
		hovering = false
		return
	emit_signal("clicked")

func _on_Timer_timeout():
	timer.stop()
	hovering = true
	if cleared: return
	emit_signal("show_tooltip")

func get_connections() -> int:
	var result = 0
	if up != Vector2.ZERO:
		result += 1
	if down != Vector2.ZERO:
		result += 1
	if left != Vector2.ZERO:
		result += 1
	if right != Vector2.ZERO:
		result += 1
	return result

func set_dir(dir: Vector2, _pos: Vector2) -> void:
	if dir == Vector2.UP:
		up = _pos
	elif dir == Vector2.DOWN:
		down = _pos
	elif dir == Vector2.LEFT:
		left = _pos
	else:
		right = _pos

func get_dir(dir: Vector2) -> Vector2:
	if dir == Vector2.UP:
		return up
	elif dir == Vector2.DOWN:
		return down
	elif dir == Vector2.LEFT:
		return left
	else:
		return right
