extends Control

var _Button = preload("res://src/potions/PotionButton.tscn")
var _Viewer = preload("res://src/potions/PotionViewer.tscn")

onready var tween = $Tween
onready var items = $Items

var player: PlayerUI

func initialize(actions: Actions, potions, enemy) -> void:
	invis()
	clear_items()
	for potion in potions:
		var child = _Button.instance() as PotionButton
		items.add_child(child)
		child.initialize(actions, potion, enemy)

func add_potion(potion: Action) -> void:
		var child = _Viewer.instance() as PotionViewer
		items.add_child(child)
		child.initialize(player, potion)

func init_ui(playerUI: PlayerUI) -> void:
	player = playerUI
	items.modulate.a = 1
	clear_items()
	for potion in player.player.potions:
		add_potion(potion)

func clear_items() -> void:
	for child in items.get_children():
		child.queue_free()

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
