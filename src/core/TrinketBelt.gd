extends Control

var _Button = preload("res://src/trinkets/TrinketButton.tscn")

onready var tween = $Tween
onready var trinkets = $Trinkets

func initialize(player: PlayerUI) -> void:
	trinkets.modulate.a = 1
	clear_trinkets()
	for trinket in player.player.trinkets:
		var child = _Button.instance() as TrinketButton
		trinkets.add_child(child)
		child.initialize(player, trinket)

func clear_trinkets() -> void:
	for child in trinkets.get_children():
		child.queue_free()

func consume(button) -> void:
	pass
#	trinkets.remove_child(button)

func show() -> void:
	.show()
	tween.interpolate_property(trinkets, "modulate",
		Color(modulate.r, modulate.g, modulate.b, 0),
		Color(modulate.r, modulate.g, modulate.b, 1),
		0.05, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(trinkets, "rect_position",
		Vector2(0, 5),
		Vector2.ZERO,
		0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")

func hide() -> void:
	tween.interpolate_property(trinkets, "modulate",
		Color(modulate.r, modulate.g, modulate.b, 1),
		Color(modulate.r, modulate.g, modulate.b, 0),
		0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(trinkets, "rect_position",
		Vector2.ZERO,
		Vector2(0, 5),
		0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	.hide()

func invis() -> void:
	trinkets.modulate.a = 0
