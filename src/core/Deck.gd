extends Node2D

var _ActionChoice = preload("res://src/core/ActionChoice.tscn")

signal show_card(btn, count)
signal hide_card

onready var deck: = $InputBlock/ScrollContainer/Deck
onready var banner: = $InputBlock/ColorRect/Banner

var player: Actor
var chosen_action: Action
var clickable: bool
var selection: int

func initialize(_player: Actor) -> void:
	hide()
	player = _player
	refresh(0)

func refresh(amt: int) -> void:
	selection = amt
	if selection > 0:
		clickable = true
	else:
		clickable = false
	player.actions.sort_custom(ActionSorter, "sort")
	banner.text = str(player.actions.size()) + " Equipped Actions"
	fill_deck()

func fill_deck() -> void:
	for child in deck.get_children():
		deck.remove_child(child)
		child.queue_free()
	for action in player.actions:
		var action_button = _ActionChoice.instance() as ActionChoice
		initialize_button(action_button, action)
		deck.add_child(action_button)

func initialize_button(action_button: ActionChoice, action: Action) -> void:
	action_button.connect("show_card", self, "_on_show_card")
	action_button.connect("hide_card", self, "_on_hide_card")
	action_button.connect("chosen", self, "choose")
	action_button.initialize(action, player)

func choose(choice: ActionChoice) -> void:
	if !clickable: return
	for child in deck.get_children():
		if child == choice:
			child.chosen = !child.chosen
			if child.chosen:
				AudioController.click()
				chosen_action = child.action
			else:
				AudioController.back()
				chosen_action = null
		else:
			child.chosen = false

func clear_choice() -> void:
	for child in deck.get_children():
		child.chosen = false

func _on_show_card(btn: ActionChoice) -> void:
	var count = 0
	for a in player.actions:
		if a.name == btn.action.name:
			count += 1
	emit_signal("show_card", btn, count)

func _on_hide_card():
	emit_signal("hide_card")

func _on_Close_button_up():
	AudioController.back()
	clear_choice()
	hide()
