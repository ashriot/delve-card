extends Position2D
class_name FloatingText

onready var tween = $Tween

export var gravity: = Vector2(0, 1)
export var mass: = 200

var velocity: Vector2
var text setget set_text
var crit: = false

func _ready() -> void:
	tween.interpolate_property(self, "modulate",
		Color(modulate.r, modulate.g, modulate.b, modulate.a),
		Color(modulate.r, modulate.g, modulate.b, 0.0),
		0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.8)

	tween.interpolate_property(self, "scale",
		Vector2(0.1, 0.1),
		Vector2(1.0, 1.0) * Vector2(2.0, 2.0) if crit else Vector2(1.0, 1.0),
		0.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	
	tween.interpolate_property(self, "scale",
		Vector2(1.0, 1.0),
		Vector2(0.4, 0.4),
		1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1.0)
	
	tween.interpolate_callback(self, 1.0, "queue_free")
	
	velocity = Vector2(rand_range(-30, 30), -80)
	
	tween.start()

func _process(delta) -> void:
	velocity += gravity * mass * delta
	position += velocity * delta

func initialize(_text: int, _crit: bool) -> void:
	self.text = str(_text)
	crit = _crit

func display_text(value: String) -> void:
	$LeftShadow.text = (value)
	$RightShadow.text = (value)
	$Label.text = (value)

func set_text(value: String) -> void:
	$LeftShadow.text = str(value)
	$RightShadow.text = str(value)
	$Label.text = str(value)
