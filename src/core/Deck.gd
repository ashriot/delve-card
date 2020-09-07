extends Node2D

var _ActionChoice = preload("res://src/core/ActionChoice.tscn")

onready var deck: = $InputBlock/DeckPanel/ScrollContainer/Deck
onready var card: = $InputBlock/Card

var actions: Array
var player: Actor
var chosen_action: Action

func initialize(_player: Actor) -> void:
	hide()
	player = _player
	actions = player.actions
	fill_deck()

func fill_deck() -> void:
	for child in deck.get_children():
		deck.remove_child(child)
		child.queue_free()
	for action in actions:
		actions.sort()
		var action_button = _ActionChoice.instance() as ActionChoice
		initialize_button(action_button, action)
		deck.add_child(action_button)

func initialize_button(action_button: ActionChoice, action: Action) -> void:
	action_button.connect("show_card", self, "_on_show_card")
	action_button.connect("hide_card", self, "_on_hide_card")
	action_button.connect("chosen", self, "choose")
	action_button.initialize(action, player)

func choose(choice: ActionChoice) -> void:
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
	card.initialize(btn, count)

func _on_hide_card():
	card.close()

func _on_Close_button_up():
	AudioController.back()
	clear_choice()
	hide()
