extends BaseControl

var _ActionChoice = preload("res://src/core/ActionChoice.tscn")

signal show_card(btn, count)
signal hide_card
signal refresh_player

onready var deck: = $BG/ScrollContainer/Deck
onready var action: = $BG/Action
onready var cost: = $BG/Cost
onready var banner: = $BG/ColorRect/Banner
onready var cover: = $BG/Cover

var player: Actor
var blacksmith: Blacksmith
var chosen_action
var clickable: bool
var upgrading: bool
var destroying: bool
var selection: int

func initialize(game) -> void:
	connect("refresh_player", game, "refresh_player")
	hide()
	player = game.player
	refresh(0)

func refresh(amt: int) -> void:
	resize_cover()
	selection = amt
	if selection > 0:
		clickable = true
	else:
		clickable = false
	player.actions.sort_custom(ActionSorter, "sort")
	if amt == 0:
		banner.text = str(player.actions.size()) + " Equipped Actions"
		action.hide()
		cost.hide()
	else:
		action.show()
		disable_action()
		if upgrading:
			action.text = "Upgrade"
			banner.text = "Upgrade an Action"
		elif destroying:
			action.text = "Destroy"
			banner.text = "Destroy an Action"
	fill_deck()

func smithing(_blacksmith: Blacksmith) -> void:
	blacksmith = _blacksmith
	upgrading = blacksmith.upgrading
	destroying = blacksmith.destroying
	refresh(1)

func resize_cover() -> void:
	if upgrading or destroying:
		$BG/ScrollContainer.rect_size.y = 145
		cover.rect_size.y = 28
		cover.rect_position.y = 155
	else:
		$BG/ScrollContainer.rect_size.y = 157
		cover.rect_size.y = 15
		cover.rect_position.y = 168

func fill_deck() -> void:
	for child in deck.get_children():
		deck.remove_child(child)
		child.queue_free()
	for action in player.actions:
		var action_button = _ActionChoice.instance() as ActionChoice
		initialize_button(action_button, action)
		deck.add_child(action_button)

func initialize_button(action_button: ActionChoice, act: Action) -> void:
	action_button.connect("show_card", self, "_on_show_card")
	action_button.connect("hide_card", self, "_on_hide_card")
	action_button.connect("chosen", self, "choose")
	action_button.initialize(act, player)

func choose(choice: ActionChoice) -> void:
	if !clickable: return
	for child in deck.get_children():
		if child == choice:
			child.chosen = !child.chosen
			if child.chosen:
				AudioController.click()
				enable_action()
				chosen_action = child
			else:
				disable_action()
				AudioController.back()
				chosen_action = null
		else:
			child.chosen = false

func enable_action() -> void:
	var able = player.have_enough_gold(blacksmith.cost)
	action.disabled = !able
	cost.text = str(blacksmith.cost)
	cost.show()

func disable_action() -> void:
	action.disabled = true
	cost.hide()

func clear_choice() -> void:
	for child in deck.get_children():
		child.chosen = false
	upgrading = false
	destroying = false

func upgrade_card() -> void:
	pass

func destroy_card() -> void:
	AudioController.play_sfx("destroy")
	player.remove_action(chosen_action.action)
	player.spend_gold(blacksmith.cost)
	chosen_action.queue_free()
	blacksmith.destroy_card()
	cost.text = str(blacksmith.cost)
	chosen_action = null
	action.disabled = true
	emit_signal("refresh_player")

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

func _on_Action_button_up():
	if upgrading:
		upgrade_card()
		return
	if destroying:
		destroy_card()
		return
