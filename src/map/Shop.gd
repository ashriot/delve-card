extends BaseControl

var _ActionChoice = preload("res://src/core/ActionChoice.tscn")

signal show_card(card, qty)
signal hide_card
signal shop_purchase(action)

onready var class_button = $BG/Menu/ClassActions
onready var action_dialog = $BG/ActionDialog
onready var other_dialog = $BG/OtherDialog
onready var buy_btn = $BG/ActionDialog/Buy
onready var buy_cost = $BG/ActionDialog/Buy/Cost
onready var other_buy = $BG/OtherDialog/Buy
onready var other_cost = $BG/OtherDialog/Buy/Cost
onready var choices = $BG/ActionDialog/Choices
onready var other_choices = $BG/OtherDialog/Choices
onready var price_tags = $BG/ActionDialog/PriceTags
onready var other_tags = $BG/OtherDialog/PriceTags

var player: Actor
var chosen_action: Action setget set_chosen_action

var square_id: int

func initialize(game) -> void:
	player = game.player
	class_button.text = game.player.name + " Actions"
	action_dialog.hide_instantly()
	buy_cost.hide()
	buy_btn.disabled = true

func display(actions: Array, _square_id: int) -> void:
	square_id = _square_id
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
	update_price_tags()
	self.show()

func display_others(actions: Array) -> void:
	for child in other_choices.get_children():
		other_choices.remove_child(child)
		child.queue_free()

	for res in actions:
		var action = load(res)
		var child = _ActionChoice.instance()
		child.initialize(action, player)
		child.connect("show_card", self, "_on_show_card")
		child.connect("hide_card", self, "_on_hide_card")
		child.connect("chosen", self, "choose")
		other_choices.add_child(child)
	update_other_price_tags()

func update_price_tags() -> void:
	for tag in price_tags.get_children():
		var index = tag.get_index()
		if index >= choices.get_child_count():
			tag.hide()
		else:
			tag.show()
			var child = choices.get_child(index)
			var cost = child.action.rarity * 20
			var label = tag.find_node("Label")
			label.text = str(cost)
			if player.gold < cost:
				label.modulate.a = 0.5
				child.disable(true)
			else:
				label.modulate.a = 1.0
				child.disable(false)

func update_other_price_tags() -> void:
	for tag in other_tags.get_children():
		var index = tag.get_index()
		if index >= other_choices.get_child_count():
			tag.hide()
		else:
			tag.show()
			var child = other_choices.get_child(index)
			var cost = child.action.rarity * 10
			var label = tag.find_node("Label")
			label.text = str(cost)
			if player.gold < cost:
				label.modulate.a = 0.5
				child.disable(true)
			else:
				label.modulate.a = 1.0
				child.disable(false)

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

func _on_Buy_pressed():
	AudioController.confirm()
	var cost = chosen_action.rarity * 10
	player.gold -= cost
	for child in choices.get_children():
		if child.chosen:
			gain_purchase()
			emit_signal("shop_purchase", child.get_index(), square_id)
			choices.remove_child(child)
			child.queue_free()
			self.chosen_action = null
			update_price_tags()
			return

func gain_purchase() -> void:
	if chosen_action.action_type == Action.ActionType.PERMANENT:
		if chosen_action.damage_type == Action.DamageType.HP:
			player.max_hp += chosen_action.damage
			player.hp += chosen_action.damage
		elif chosen_action.damage_type == Action.DamageType.MP:
			player.initial_mp += chosen_action.damage
	else:
		player.actions.append(chosen_action)

# SETTERS

func set_chosen_action(value) -> void:
	var disabled = true if value == null else false
	chosen_action = value
	buy_btn.disabled = disabled
	if value != null:
		buy_cost.show()
		buy_cost.text = str(chosen_action.rarity * 10)
	else:
		buy_cost.hide()
