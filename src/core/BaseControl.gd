extends Control
class_name BaseControl

signal done

onready var tween = $Tween
onready var bg = $BG

func show(move:= true) -> void:
	.show()
	tween.interpolate_property(self, "modulate",
		Color(modulate.r, modulate.g, modulate.b, 0),
		Color(modulate.r, modulate.g, modulate.b, 1),
		0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	if move:
		tween.interpolate_property(self, "rect_position",
			Vector2(12, 0),
			Vector2.ZERO,
			0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	emit_signal("done")

func hide(move:= true) -> void:
	tween.interpolate_property(self, "modulate",
		Color(modulate.r, modulate.g, modulate.b, 1),
		Color(modulate.r, modulate.g, modulate.b, 0),
		0.15, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if move:
		tween.interpolate_property(self, "rect_position",
			Vector2.ZERO,
			Vector2(-12, 0),
			0.15, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")
	.hide()
	emit_signal("done")

func hide_instantly() -> void:
	.hide()
