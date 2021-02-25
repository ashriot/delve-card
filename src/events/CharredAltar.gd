extends Event

func begin() -> void:
	print("Begin!")
	.display_text(desc)

func _on_Choice1_pressed():
	if $Desc.percent_visible < 1:
		show_text()
		return
	if stage == 0:
		AudioController.click()
		var black_stone = load("res://src/trinkets/black_stone.tres") as Trinket
		playerUI.add_trinket(black_stone)
		var text = "You grab the black stone. It is warm to the touch almost as " + \
		"if is alive.\n\n" + \
		"You continue on."
		var array = ["Return to map."]
		.display_text(text)
		.choices(array)
		stage = 1
	elif stage == 1:
		emit_signal("done")

func _on_Choice2_pressed():
	if $Desc.percent_visible < 1:
		show_text()
		return
	pass # Replace with function body.

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
