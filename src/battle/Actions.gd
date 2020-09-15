extends Node2D
class_name Actions

var _ActionButton: = preload("res://src/battle/ActionButton.tscn")
var FloatingText = preload("res://assets/animations/FloatingText.tscn")

signal deck_count(value)
signal graveyard_count(value)
signal weapons_played(amt)
signal graveyard_done
signal ended_turn
signal done_discarding
signal done_filling_hand
signal done_drawing
signal done_adding_to_deck
signal done_pressing
signal show_card(btn, qty)
signal hide_card

export var HAND_SIZE: = 5

onready var input_blocker: = $InputBlocker
onready var hand: = $Hand
onready var pos1: = $Hand/Pos1
onready var pos2: = $Hand/Pos2
onready var pos3: = $Hand/Pos3
onready var pos4: = $Hand/Pos4
onready var pos5: = $Hand/Pos5
onready var deck_viewer: = $DeckViewer
onready var deck_tween = $DeckViewer/Tween
onready var deck: = $DeckViewer/InputBlock/ScrollContainer/Deck
onready var graveyard: = $Graveyard
onready var limbo: = $Limbo
onready var item_belt: = $ItemAnchor/ItemBelt
onready var end_turn: = $EndTurn

var auto_end: = false
var hand_count: = 0
var deck_count setget set_deck_count
var deck_order: = []
var graveyard_count setget set_graveyard_count
var player: Player
var enemyUI
var actions: Array

var weapons_played: = 0

var initialized: = false

func initialize(_player: Player, _enemyUI: Enemy) -> void:
	self.deck_count = 0
	input_blocker.show()
	player = _player
	enemyUI = _enemyUI
	actions = player.actor.actions
	item_belt.initialize(self, player.actor.potions)
	fill_deck()
	initialized = true

func reset() -> void:
	item_belt.invis()
	item_belt.initialize(self, player.actor.potions)	
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
	weapons_played = 0
	fill_deck()
	shuffle_deck()

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
		action.gain()
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

func initialize_button(action_button: ActionButton, action: Action) -> void:
	action_button.connect("unblock", self, "block_input")
	action_button.connect("draw_cards", self, "draw_cards")
	action_button.connect("action_finished", self, "action_finished")
	action_button.connect("button_pressed", self, "button_pressed")
	action_button.connect("show_card", self, "show_card")
	action_button.connect("hide_card", self, "hide_card")
	connect("weapons_played", action_button, "weapons_played")
	action_button.initialize(action, player, enemyUI)

func fill_hand() -> void:
	while (hand_count < HAND_SIZE):
		if deck.get_child_count() == 0:
			yield(get_tree().create_timer(0.1), "timeout")
			recover_graveyard()
			yield(self, "graveyard_done")
		var action = deck.get_child(0)
		deck.remove_child(action)
		self.deck_count = deck.get_child_count()
		set_pos(action)
		action.show()
		yield(get_tree().create_timer(0.12), "timeout")
	emit_signal("done_filling_hand")
	

func set_pos(node: Control) -> void:
	for i in hand.get_child_count():
		if hand.get_child(i).get_child_count() == 0:
			hand.get_child(i).add_child(node)
			hand_count += 1
			var p = hand.get_child(i) as Position2D
			node.set_position(Vector2.ZERO)
			return

func remove_pos(node: Control) -> void:
	for i in hand.get_children():
		if i.get_child_count() > 0:
			if i.get_child(0) == node:
				i.remove_child(node)
				hand_count -= 1
				return

func add_to_deck(actions_to_add) -> void:
	var list_of_actions = []
	list_of_actions += actions_to_add
	while list_of_actions.size() > 0:
		var action = list_of_actions.pop_front() as ActionButton
		action.played = true
		player.get_parent().add_child(action)
		action.gain()
		action.rect_position = Vector2(0, 64)
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

func draw_cards(src: Action) -> void:
	block_input(true)
	for _i in range(0, src.drawX):
		if deck.get_child_count() == 0:
			if graveyard_count > 0:
				yield(get_tree().create_timer(0.1), "timeout")
				recover_graveyard()
				yield(self, "graveyard_done")
			else: return
		if src.draw_type != Action.ActionType.ANY:
			pass
		var action = find_card_by_type(src.draw_type)
		if action == null:
			block_input(false)
			return
		deck.remove_child(action)
		self.deck_count = deck.get_child_count()
		if hand_count == HAND_SIZE:
			graveyard.add_child(action)
			self.graveyard_count += 1
		else:
			set_pos(action)
			action.show()
		yield(get_tree().create_timer(0.12), "timeout")
	block_input(false)
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
				if child.played:
					continue
				else:
					child.discard()
					yield(child, "discarded")
					remove_pos(child)
					if child.action.fade:
						child.queue_free()
					else:
						graveyard.add_child(child)
						self.graveyard_count += 1
	yield(get_tree().create_timer(0.2), "timeout")
	emit_signal("done_discarding")

func action_finished(action_button: ActionButton) -> void:
	if action_button.action.action_type == Action.ActionType.WEAPON:
		weapons_played += 1
		emit_signal("weapons_played", weapons_played)
	print("action finished: Actions")
	if !action_button.action.drop \
	and !action_button.action.fade \
	and !action_button.action.consume:
		limbo.remove_child(action_button)
		graveyard.add_child(action_button)
		self.graveyard_count += 1
	else:
		yield(get_tree().create_timer(0.5), "timeout")
		action_button.queue_free()

func button_pressed(action_button: ActionButton) -> void:
	block_input(true)
	var pos = action_button.rect_global_position
	limbo.set_global_position(pos)
	remove_pos(action_button)
	limbo.add_child(action_button)
	emit_signal("done_pressing")

func block_input(block: bool) -> void:
	if block:
		input_blocker.show()
	else:
		input_blocker.hide()
		if hand_count == 0 && auto_end:
			end_turn()

func used_potion(button: PotionButton) -> void:
	button.execute()

func _on_EndTurn_button_up():
	AudioController.click()
	end_turn()

func end_turn() -> void:
	input_blocker.show()
	item_belt.hide()
	end_turn.hide()
	weapons_played = 0
	emit_signal("weapons_played", 0)
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

func show_card(action_button) -> void:
	var count = 0
	if action_button.action.action_type != Action.ActionType.ITEM:
		for a in actions:
			if a.name == action_button.action.name:
				count += 1
	emit_signal("show_card", action_button, count)

func hide_card() -> void:
	emit_signal("hide_card")

func _on_Battle_start_turn():
	player.start_turn()
	fill_hand()
	yield(self, "done_filling_hand")
	item_belt.show()
	get_tree().call_group("action_button", "update_data")
	AudioController.play_sfx("player_turn")
	block_input(false)
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

func _on_Player_apply_debuff(debuff: Buff, qty: int):
	enemyUI.gain_debuff(debuff, qty)

func show_deck_viewer() -> void:
	if deck_tween.is_active(): return	
	AudioController.click()
	for child in deck.get_children():
		deck_order.append(child)
	var sorted = deck_order.duplicate(true)
	sorted.sort_custom(ActionSorter, "sort_btns")
	for child in deck.get_children():
		deck.move_child(child, sorted.find(child))
	
	deck_viewer.global_position = Vector2.ZERO
	deck_tween.interpolate_property(deck_viewer, "modulate",
		Color(modulate.r, modulate.g, modulate.b, 0),
		Color(modulate.r, modulate.g, modulate.b, 1),
		0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	deck_tween.start()
	yield(deck_tween, "tween_all_completed")

func _on_Close_button_up():
	if deck_tween.is_active(): return
	AudioController.back()
	deck_tween.interpolate_property(deck_viewer, "modulate",
		Color(modulate.r, modulate.g, modulate.b, 1),
		Color(modulate.r, modulate.g, modulate.b, 0),
		0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	deck_tween.start()
	yield(deck_tween, "tween_all_completed")
	for child in deck.get_children():
		deck.move_child(child, deck_order.find(child))
	deck_viewer.modulate.a = 0
	deck_viewer.global_position = Vector2(-112, 0)
