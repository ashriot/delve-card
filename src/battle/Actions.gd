extends Node2D
class_name Actions

var _ActionButton: = preload("res://src/battle/ActionButton.tscn")
var FloatingText = preload("res://assets/animations/FloatingText.tscn")

signal deck_count(value)
signal graveyard_count(value)
signal graveyard_done
signal ended_turn
signal done_discarding
signal done_filling_hand
signal done_drawing
signal done_adding_to_deck

export var HAND_SIZE: = 5

onready var input_blocker: = $Hand/InputBlocker
onready var card = $Card
onready var hand: = $Hand
onready var pos1: = $Hand/Pos1
onready var pos2: = $Hand/Pos2
onready var pos3: = $Hand/Pos3
onready var pos4: = $Hand/Pos4
onready var pos5: = $Hand/Pos5
onready var deck: = $Deck
onready var graveyard: = $Graveyard
onready var end_turn: = $EndTurn

var hand_count: = 0
var deck_count setget set_deck_count
var graveyard_count setget set_graveyard_count
var player: Player
var enemyUI
var actions: Array

var initialized: = false

func initialize(_player: Player, _enemyUI: Enemy) -> void:
	self.deck_count = 0
	input_blocker.show()
	player = _player
	enemyUI = _enemyUI
	actions = player.actor.actions
	fill_deck()
	initialized = true

func shuffle_deck() -> void:
	self.deck_count = deck.get_child_count()
	var shuffler = range(0, deck_count)
	shuffler.shuffle()
	if deck_count < 2: return
	for i in shuffler:
		var child = deck.get_child(i)
		deck.move_child(child, 0)

func display_message(value: String) -> void:
	var floating_text = FloatingText.instance()
	floating_text.display_text(value)
	player.add_child(floating_text)

func recover_graveyard() -> void:
	display_message("Shuffling...")
	var i = 0
	while graveyard.get_child_count() > 0:
		i += 1
		var action = graveyard.get_child(0)
		graveyard.remove_child(action)
		deck.add_child(action)
		self.graveyard_count = graveyard.get_child_count()
		self.deck_count = deck.get_child_count()
		if i == 3:
			AudioController.play_sfx("draw")
			i = 0
		yield(get_tree().create_timer(0.01), "timeout")
	yield(get_tree().create_timer(0.1), "timeout")
	emit_signal("graveyard_done")
	shuffle_deck()

func fill_deck() -> void:
	if deck_count > 0:
		for child in deck.get_children():
			deck.remove_child(child)
			child.queue_free()
		self.deck_count = deck.get_child_count()
	for action in actions:
		var action_button = _ActionButton.instance() as ActionButton
		initialize_button(action_button, action)
		deck.add_child(action_button)
	self.deck_count = deck.get_child_count()

func reset_deck() -> void:
	while graveyard.get_child_count() > 0:
		var action = graveyard.get_child(0)
		graveyard.remove_child(action)
		action.queue_free()
	if hand_count > 0:
		for i in hand.get_children():
			if i.get_child_count() > 0:
				var child = i.get_child(0)
				remove_pos(child)
				child.queue_free()
	hand_count = 0
	self.graveyard_count = 0
	fill_deck()
	shuffle_deck()

func initialize_button(action_button: ActionButton, action: Action) -> void:
	action_button.connect("played", self, "played_action")
	action_button.connect("action_finished", self, "action_finished")
	action_button.connect("button_pressed", self, "block_input")
	action_button.connect("show_card", self, "show_card")
	action_button.connect("hide_card", self, "hide_card")
	action_button.initialize(action, player, enemyUI)

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
	emit_signal("done_filling_hand")

func set_pos(node: Control) -> void:
	for i in hand.get_child_count():
		if hand.get_child(i).get_child_count() == 0:
			hand.get_child(i).add_child(node)
			hand_count += 1
			return

func remove_pos(node: Control) -> void:
	for i in hand.get_children():
		if i.get_child_count() > 0:
			if i.get_child(0) == node:
				i.remove_child(node)
				return

func add_to_deck(actions_to_add) -> void:
	var list_of_actions = []
	list_of_actions += actions_to_add
	while list_of_actions.size() > 0:
		var action = list_of_actions.pop_front() as ActionButton
		action.played = true
		player.get_parent().add_child(action)
		action.rect_position = Vector2(54, 72)
		action.animationPlayer.play("Gain")
		yield(get_tree().create_timer(0.65), "timeout")	
		player.get_parent().remove_child(action)
		action.rect_position = Vector2.ZERO
		deck.add_child(action)
		self.deck_count = deck.get_child_count()
		AudioController.play_sfx("draw")
	yield(get_tree().create_timer(0.1), "timeout")	
	shuffle_deck()
	emit_signal("done_adding_to_deck")

func draw(value: int, type) -> void:
	input_blocker.show()
	for _i in range(0, value):
		if deck.get_child_count() == 0:
			if graveyard_count > 0:
				yield(get_tree().create_timer(0.1), "timeout")
				recover_graveyard()
				yield(self, "graveyard_done")
			else: return
		if type != Action.ActionType.ANY:
			pass
		var action = find_card_by_type(type)
		if action == null:
			input_blocker.hide()
			return
		deck.remove_child(action)
		self.deck_count -= 1
		if hand_count == HAND_SIZE:
			action.discard()
		else:
			set_pos(action)
			action.show()
		yield(get_tree().create_timer(0.12), "timeout")
	input_blocker.hide()
	emit_signal("done_drawing")

func find_card_by_type(type) -> ActionButton:
	if type == Action.ActionType.ANY:
		return deck.get_child(0) as ActionButton
	for child in deck.get_children():
		child = child as ActionButton
		if child.action.action_type == type:
			return child
	return null

func discard_hand() -> void:
	if hand_count > 0:
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
	if action_button.action.drawX > 0:
		draw(action_button.action.drawX, action_button.action.draw_type)
		yield(self, "done_drawing")
	if !action_button.action.drop and !action_button.action.consume:
		graveyard.add_child(action_button)
		self.graveyard_count += 1

func action_finished(action_button: ActionButton) -> void:
	block_input(false)

func block_input(block: bool) -> void:
	if block:
		input_blocker.show()
	else:
		input_blocker.hide()

func _on_EndTurn_button_up():
	AudioController.click()
	input_blocker.show()
	end_turn.hide()
	if hand_count > 0:
		discard_hand()
		yield(self, "done_discarding")
	emit_signal("ended_turn")

func set_deck_count(value: int) -> void:
	deck_count = value
	emit_signal("deck_count", value)

func set_graveyard_count(value: int) -> void:
	graveyard_count = value
	emit_signal("graveyard_count", value)

func show_card(action_button: ActionButton) -> void:
	var count = 0
	for a in actions:
		print(a.name +" == " + action_button.action.name)
		if a.name == action_button.action.name:
			count += 1
	card.initialize(action_button, count)

func hide_card() -> void:
	card.close()

func _on_Battle_start_turn():
	fill_hand()
	yield(self, "done_filling_hand")
	AudioController.play_sfx("player_turn")
	block_input(false)
	player.start_turn()
	end_turn.show()

func _on_Player_add_to_deck(action_name: String, qty: int):
	var btns = []
	for i in qty:
		var action_button = _ActionButton.instance()
		var action = load("res://src/actions/created/" + action_name + ".tres")
		initialize_button(action_button, action)
		btns.append(action_button)
	add_to_deck(btns)
	yield(self,"done_adding_to_deck")
