extends BaseControl

onready var class_button = $BG/Choices/ClassActions
onready var action_dialog = $BG/ActionDialog

func initialize(game) -> void:
	class_button.text = game.player.name + " Actions"
	action_dialog.hide_instantly()

func show(move: = true) -> void:
	$BG/Choices/Exit.mouse_filter = Control.MOUSE_FILTER_STOP
	AudioController.click()
	.show(move)

func _on_Exit_pressed():
	$BG/Choices/Exit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.back()
	hide()

func _on_ClassActions_pressed():
	AudioController.click()
	action_dialog.show()

func _on_Back_pressed():
	$BG/ActionDialog/Back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.back()
	action_dialog.hide()
	yield(action_dialog, "done")
	$BG/ActionDialog/Back.mouse_filter = Control.MOUSE_FILTER_STOP
