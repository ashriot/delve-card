extends Button

signal chose(username)
signal deleted(username)

onready var del = $Del

func initialize(username: String):
	text = username

func _on_Profile_pressed():
	AudioController.click()
	emit_signal("chose", text)

func _on_Del_pressed():
	AudioController.back()
	emit_signal("deleted", text)
