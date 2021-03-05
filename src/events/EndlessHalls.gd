extends Event

func begin() -> void:
	print("Begin!")
	.display_text(desc)

func _on_Choice1_pressed():
	print(stage)
	if $Desc.percent_visible < 1:
		show_text()
		return
	AudioController.click()
	self.scene = 22
	if stage == 0:
		lose_hp(2)
		var text = "You go to the left."
		.display_text(text)
		.choices(["Go left. (-2 HP)", "Go forward. (-2 HP)", "Go right. (-2 HP)", "Leave this place."])
		stage = 1
	elif stage == 4:
		emit_signal("done")
	elif stage == 5:
		var text = "You are at the entrance."
		.display_text(text)
		.choices(["Go left. (-2 HP)", "Go forward. (-2 HP)", "Go right. (-2 HP)", "Leave this place."])
		stage = 0
	else:
		self.scene = 64
		lose_hp(2)
		var text = "You go to the left. You've reached a deadend."
		.display_text(text)
		.choices(["Retrace your steps."])
		stage = 5

func _on_Choice2_pressed():
	print(stage)
	if $Desc.percent_visible < 1:
		show_text()
		return
	AudioController.click()
	self.scene = 1
	if stage == 2:
		lose_hp(2)
		var text = "You continue forward."
		.display_text(text)
		.choices(["Go left. (-2 HP)", "Go forward. (-2 HP)", "Go right. (-2 HP)", "Leave this place."])
		stage += 1
	else:
		self.scene = 64
		lose_hp(2)
		var text = "You continue forward. You've reached a deadend."
		.display_text(text)
		.choices(["Retrace your steps."])
		stage = 5

func _on_Choice3_pressed():
	print(stage)
	if $Desc.percent_visible < 1:
		show_text()
		return
	AudioController.click()
	self.scene = 85
	if stage == 1:
		lose_hp(2)
		var text = "You go to the right."
		.display_text(text)
		.choices(["Go left. (-2 HP)", "Go forward. (-2 HP)", "Go right. (-2 HP)", "Leave this place."])
		stage = 2
	elif stage == 3:
		lose_hp(2)
		var text = "You've reached a large, open room with a beautiful fountain in the center " + \
			"filled with pure water." + \
			"\n\nTaking a sip, your wounds begin to heal and you feel stronger than ever. (HP+5)"
		heal(30)
		max_hp_increase(5)
		.display_text(text)
		.choices(["Return to map."])
		stage = 4
	else:
		self.scene = 64
		lose_hp(2)
		var text = "You go to the right. You've reached a deadend."
		.display_text(text)
		.choices(["Retrace your steps."])
		stage = 5

func _on_Choice4_pressed():
	if $Desc.percent_visible < 1:
		show_text()
		return
	AudioController.click()
	var text = "You continue on."
	var array = ["Return to map."]
	.display_text(text)
	.choices(array)
	stage = 4
