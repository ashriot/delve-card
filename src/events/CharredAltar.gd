extends Event


func begin() -> void:
	print("Begin!")
	.display_text(desc)


func _on_Choice1_pressed():
	if stage == 0:
		AudioController.click()
		var text = "You grab the black orb. It is warm to the touch almost as " + \
		"if is alive. It doesn't seem to have any other effect, however.\n\n" + \
		"You continue on."
		var array = ["Return to map."]
		.display_text(text)
		.choices(array)
		stage = 1
	elif stage == 1:
		emit_signal("done")


func _on_Choice2_pressed():
	pass # Replace with function body.


func _on_Choice3_pressed():
	pass # Replace with function body.


func _on_Choice4_pressed():
	pass # Replace with function body.
