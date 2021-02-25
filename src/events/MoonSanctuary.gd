extends Event

func begin() -> void:
	print("Begin!")
	if !playerUI.has_trinket("Black Stone"):
		btn1.disabled = true
	.display_text(desc)

func _on_Choice1_pressed():
	if $Desc.percent_visible < 1:
		show_text()
		return
	AudioController.click()
	if stage == 0:
		stage = 1
		btn1.disabled = false
		var text = "You place the black stone into the pedestal. " + \
		"\n\nThe ceiling begins to move. Suddenly, the stone begins to fade between " + \
		"two colors, grey and white."
		$Scene.frame = 32

		.display_text(text)
		.choices(["Take the grey stone.", "Take the white stone."])
	elif stage == 1:
		stage = 2
		playerUI.remove_trinket("Black Stone")
		var trinket = load("res://src/trinkets/lunar_stone.tres") as Trinket
		playerUI.add_trinket(trinket)
		.display_text("You take the lunar stone and continue on.")
		.choices(["Return to map."])
	elif stage == 2:
		emit_signal("done")

func _on_Choice2_pressed():
	if $Desc.percent_visible < 1:
		show_text()
		return
	AudioController.click()
	if stage == 0:
		stage = 2
		btn1.disabled = false
		var text = "You speak a quiet prayer to Luna. " + \
		"\n\nYou suddenly feel at ease. " + \
		"\n\n(HP restored to full.)"
		playerUI.full_heal()
		.display_text(text)
		.choices(["Return to map."])
	elif stage == 1:
		stage = 2
		playerUI.remove_trinket("Black Stone")
		var trinket = load("res://src/trinkets/solar_stone.tres") as Trinket
		playerUI.add_trinket(trinket)
		.display_text("You take the solar stone and continue on.")
		.choices(["Return to map."])

func _on_Choice3_pressed():
	if $Desc.percent_visible < 1:
		show_text()
		return
	AudioController.click()
	var text = "You continue on."
	var array = ["Return to map."]
	.display_text(text)
	.choices(array)
	stage = 1

func _on_Choice4_pressed():
	if $Desc.percent_visible < 1:
		show_text()
		return
