extends Control
# Blacksmith.gd

signal open_deck(amt, type)

onready var node = $Node2D
onready var tween = $Node2D/Tween
onready var upgrade = $Node2D/ColorRect/Choices/Upgrade

func initialize(player: PlayerUI) -> void:
	connect("open_deck", player, "open_deck")
	upgrade.connect("button_up", self, "_on_Upgrade_button_up", [upgrade])

func show() -> void:
	.show()
	tween.interpolate_property(node, "modulate",
		Color(modulate.r, modulate.g, modulate.b, 0),
		Color(modulate.r, modulate.g, modulate.b, 1),
		0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	tween.interpolate_property(node, "position",
		Vector2(5, 0),
		Vector2.ZERO,
		0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	
	yield(tween, "tween_all_completed")

func _on_Upgrade_button_up(button):
	AudioController.click()
	emit_signal("open_deck", 1, button.text)

func _on_Exit_button_up():
	AudioController.back()
	tween.interpolate_property(node, "modulate",
		Color(modulate.r, modulate.g, modulate.b, 1),
		Color(modulate.r, modulate.g, modulate.b, 0),
		0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	tween.interpolate_property(node, "position",
		Vector2.ZERO,
		Vector2(-5, 0),
		0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	hide()
