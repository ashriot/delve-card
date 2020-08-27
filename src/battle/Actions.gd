extends Node2D
class_name Actions

var _ActionButton: = preload("res://src/battle/ActionButton.tscn")
var FloatingText = preload("res://assets/animations/FloatingText.tscn")

signal deck_count(value)
signal graveyard_count(value)
signal graveyard_done
signal ended_turn
signal done_discarding

export var HAND_SIZE: = 5

onready var input_blocker: = $Hand/InputBlocker
onready var hand: = $Hand
onready var pos1: = $Hand/Pos1
onready var pos2: = $Hand/Pos2
onready var pos3: = $Hand/Pos3
onready var pos4: = $Hand/Pos4
onready var pos5: = $Hand/Pos5
onready var deck: = $Deck
onready var graveyard: = $Graveyard
onready var end_turn: = $EndTurn

var hand_count
var deck_count setget set_deck_count
var graveyard_count setget set_graveyard_count
var player: Player
var enemyUI
var actions: Array

var initialized: = false

func initialize(_player: Player, _enemyUI: Enemy) -> void:
	input_blocker.show()
	player = _player
	enemyUI = _enemyUI
	actions = player.actor.actions
	fill_deck()
	shuffle_deck()
	hand_count = 0
	fill_hand()
	self.graveyard_count = 0
	initialized = true

func shuffle_deck() -> void:
	var deck_size = deck.get_child_count()
	var shuffler = range(0, deck_size)
	shuffler.shuffle()
	if deck_size < 2: return
	for i in shuffler:
		var child = deck.get_child(i)
		deck.move_child(child, 0)

func display_message(value: String) -> void:
	var floating_text = FloatingText.instance()
	floating_text.display_text(value)
	player.add_child(floating_text)

func recover_graveyard() -> void:
	display_message("Shuffling...")
	while graveyard.get_child_count() > 0:
		var action = graveyard.get_child(0)
		graveyard.remove_child(action)
		deck.add_child(action)
		self.graveyard_count = graveyard.get_child_count()
		self.deck_count = deck.get_child_count()
		AudioController.play_sfx("draw")
		yield(get_tree().create_timer(0.05), "timeout")	
	yield(get_tree().create_timer(0.1), "timeout")	
	emit_signal("graveyard_done")
	shuffle_deck()

func fill_deck() -> void:
	for action in actions:
		var action_button = _ActionButton.instance() as ActionButton
		action_button.connect("played", self, "played_action")
		action_button.connect("action_finished", self, "action_finished")
		action_button.connect("button_pressed", self, "block_input")
		action_button.initialize(action, player, enemyUI, deck, graveyard)
		deck.add_child(action_button)
	self.deck_count = deck.get_child_count()	

func fill_hand() -> void:
	while (hand_count < HAND_SIZE):
		if deck.get_child_count() == 0:
			yield(get_tree().create_timer(0.1), "timeout")
			recover_graveyard()
			yield(self, "graveyard_done")
		var action = deck.get_child(0)
		deck.remove_child(action)
		self.deck_count -= 1
		set_pos(action)
		action.show()
		yield(get_tree().create_timer(0.12), "timeout")
	if deck.get_child_count() == 0:
		recover_graveyard()
	input_blocker.hide()

func set_pos(node: Node2D) -> void:
	for i in hand.get_child_count():
		if hand.get_child(i).get_child_count() == 0:
			hand.get_child(i).add_child(node)
			hand_count += 1
			return

func remove_pos(node: Node2D) -> void:
	for i in hand.get_children():
		if i.get_child_count() > 0:
			if i.get_child(0) == node:
				i.remove_child(node)
				return

func draw(value: int) -> void:
	input_blocker.show()
	for i in range(0, value):
		if deck.get_child_count() == 0:
			yield(get_tree().create_timer(0.1), "timeout")
			recover_graveyard()
			yield(self, "graveyard_done")
		var action = deck.get_child(0)
		deck.remove_child(action)
		self.deck_count -= 1
		set_pos(action)
		action.show()
		yield(get_tree().create_timer(0.12), "timeout")
	if deck.get_child_count() == 0:
		recover_graveyard()
	input_blocker.hide()

func discard_hand() -> void:
	for i in hand.get_children():
		if i.get_child_count() > 0:
			var child = i.get_child(0)
			child.discard()
			yield(child, "discarded")
			remove_pos(child)
			self.hand_count -= 1
			graveyard.add_child(child)
			self.graveyard_count += 1
	emit_signal("done_discarding")

func played_action(action_button: ActionButton) -> void:
	remove_pos(action_button)
	self.hand_count -= 1
	graveyard.add_child(action_button)
	self.graveyard_count += 1
	if action_button.action.drawX > 0:
		draw(action_button.action.drawX)

func action_finished(action_button: ActionButton) -> void:
	block_input(false)

func block_input(block: bool) -> void:
	if block:
		input_blocker.show()
	else:
		input_blocker.hide()

func _on_EndTurn_button_up():
	input_blocker.show()
	discard_hand()
	yield(self, "done_discarding")
	emit_signal("ended_turn")

func set_deck_count(value: int) -> void:
	deck_count = value
	emit_signal("deck_count", value)

func set_graveyard_count(value: int) -> void:
	graveyard_count = value
	emit_signal("graveyard_count", value)

func _on_Battle_start_turn():
	player.start_turn()
	fill_hand()
