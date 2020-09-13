extends Control

var _Button = preload("res://src/potions/PotionButton.tscn")
var _Viewer = preload("res://src/potions/PotionViewer.tscn")

onready var tween = $Tween
onready var items = $Items

func initialize(actions: Actions, potions) -> void:
	invis()
	for potion in potions:
		var child = _Button.instance() as PotionButton
		items.add_child(child)
		child.initialize(actions, potion)

func init_ui(player: PlayerUI) -> void:
	items.modulate.a = 1
	for potion in player.player.potions:
		var child = _Viewer.instance() as PotionViewer
		items.add_child(child)
		child.initialize(player, potion)

func consume(button: PotionButton) -> void:
	items.remove_child(button)

func show() -> void:
	.show()
	tween.interpolate_property(items, "modulate",
		Color(modulate.r, modulate.g, modulate.b, 0),
		Color(modulate.r, modulate.g, modulate.b, 1),
		0.05, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(items, "rect_position",
		Vector2(0, 5),
		Vector2.ZERO,
		0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")

func hide() -> void:
	tween.interpolate_property(items, "modulate",
		Color(modulate.r, modulate.g, modulate.b, 1),
		Color(modulate.r, modulate.g, modulate.b, 0),
		0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(items, "rect_position",
		Vector2.ZERO,
		Vector2(0, 5),
		0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	.hide()

func invis() -> void:
	items.modulate.a = 0
