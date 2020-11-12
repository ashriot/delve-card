extends BaseControl

var _ActionChoice = preload("res://src/core/ActionChoice.tscn")

signal show_card(card, qty)
signal hide_card

onready var class_button = $BG/Menu/ClassActions
onready var action_dialog = $BG/ActionDialog
onready var buy_btn = $BG/ActionDialog/Buy
onready var buy_cost = $BG/ActionDialog/Buy/Cost
onready var choices = $BG/ActionDialog/Choices
onready var price_tags = $BG/ActionDialog/PriceTags

var player: Actor
var chosen_action: Action setget set_chosen_action

func initialize(game) -> void:
	player = game.player
	class_button.text = game.player.name + " Actions"
	action_dialog.hide_instantly()
	buy_cost.hide()
	buy_btn.disabled = true

func display(actions: Array) -> void:
	for child in choices.get_children():
		choices.remove_child(child)
		child.queue_free()

	for res in actions:
		var action = load(res)
		var child = _ActionChoice.instance()
		child.initialize(action, player)
		child.connect("show_card", self, "_on_show_card")
		child.connect("hide_card", self, "_on_hide_card")
		child.connect("chosen", self, "choose")
		choices.add_child(child)
		var index = child.get_index()
		var tag = price_tags.get_child(index)
		tag.find_node("Label").text = str(action.cost)
	self.show()

func show(move: = true) -> void:
	$BG/Menu/Exit.mouse_filter = Control.MOUSE_FILTER_STOP
	AudioController.click()
	.show(move)

func choose(choice: ActionChoice) -> void:
	for child in choices.get_children():
		if child == choice:
			child.chosen = !child.chosen
			if child.chosen:
				AudioController.click()
				self.chosen_action = child.action
			else:
				AudioController.back()
				self.chosen_action = null
		else:
			child.chosen = false

func _on_show_card(btn: ActionChoice) -> void:
	var count = 0
	for a in player.actions:
		if a.name == btn.action.name:
			count += 1
	emit_signal("show_card", btn, count)

func _on_hide_card():
	emit_signal("hide_card")

func _on_Exit_pressed():
	$BG/Menu/Exit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.back()
	hide()

func _on_ClassActions_pressed():
	AudioController.click()
	action_dialog.show()

func _on_Back_pressed():
	$BG/ActionDialog/Back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.back()
	self.chosen_action = null
	action_dialog.hide()
	yield(action_dialog, "done")
	for child in choices.get_children():
		child.set_chosen(false)
	$BG/ActionDialog/Back.mouse_filter = Control.MOUSE_FILTER_STOP

# SETTERS

func set_chosen_action(value) -> void:
	print(value)
	var disabled = true if value == null else false
	chosen_action = value
	buy_btn.disabled = disabled
	if value != null:
		buy_cost.show()
		buy_cost.text = str(chosen_action.cost)
	else:
		buy_cost.hide()
