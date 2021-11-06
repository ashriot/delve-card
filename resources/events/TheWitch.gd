extends Event

func begin() -> void:
	print("Begin!")
	.display_text(desc)
	print(self.gold)
	btn1.disabled = gold < 50
	btn2.disabled = gold < 15

func _on_Choice1_pressed():
	print(stage)
	if $Desc.percent_visible < 1:
		show_text()
		return
	AudioController.click()
	if stage == 0:
		stage = 1
		add_gold(-50)
		var text = "The woman hands you three small flasks.\n\"Good luck to you.\""
		.display_text(text)
		.choices(["Leave this place."])
		add_potions(3)
	elif stage == 1:
		emit_signal("done")

func _on_Choice2_pressed():
	if $Desc.percent_visible < 1:
		show_text()
		return
	AudioController.click()
	if stage == 0:
		stage = 1
		add_gold(-15)
		var text = "The woman hands you a cup of bubbling brew.\n\n" + \
		"\"This should do the trick.\"\n\nYou take a deep sip and suddenly feel much better."
		heal()
		.display_text(text)
		.choices(["Leave this place."])

func _on_Choice3_pressed():
	if $Desc.percent_visible < 1:
		show_text()
		return
	AudioController.click()

func _on_Choice4_pressed():
	if $Desc.percent_visible < 1:
		show_text()
		return
