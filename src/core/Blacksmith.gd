extends Node2D
# Blacksmith.gd

signal open_deck(amt)

func initialize(player: Player) -> void:
	connect("open_deck", player, "open_deck")

func _on_Upgrade_button_up():
	AudioController.click()
	emit_signal("open_deck", 1)

func _on_Exit_button_up():
	AudioController.back()
	hide()
