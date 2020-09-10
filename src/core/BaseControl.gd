extends Control
class_name BaseControl

onready var tween = $Tween
onready var bg = $BG

func show() -> void:
	.show()
	tween.interpolate_property(bg, "modulate",
		Color(modulate.r, modulate.g, modulate.b, 0),
		Color(modulate.r, modulate.g, modulate.b, 1),
		0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(bg, "rect_position",
		Vector2(5, 0),
		Vector2.ZERO,
		0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")

func hide() -> void:
	tween.interpolate_property(bg, "modulate",
		Color(modulate.r, modulate.g, modulate.b, 1),
		Color(modulate.r, modulate.g, modulate.b, 0),
		0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(bg, "rect_position",
		Vector2.ZERO,
		Vector2(-5, 0),
		0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	.hide()
