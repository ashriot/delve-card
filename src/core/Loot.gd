extends Node2D
class_name Loot

var _ActionChoice = preload("res://src/core/ActionChoice.tscn")

signal refresh_player(save)
signal looting_finished
signal show_card(btn, qty)
signal hide_card

onready var gold = $BG/Gold
onready var choices = $BG/Choices
onready var finished = $BG/Finished

var player: Actor
var chosen_action: Action

var loot1: Array = []
var loot2: Array = []
var loot3: Array = []
var loot4: Array = []

func initialize(game) -> void:
	connect("refresh_player", game, "refresh_player")
	player = game.player
	loot1 = get_loot(1)
	loot2 = get_loot(2)
	loot3 = get_loot(3)
	loot4 = get_loot(4)

	for _i in range(3):
		var child = _ActionChoice.instance()
		child.connect("show_card", self, "_on_show_card")
		child.connect("hide_card", self, "_on_hide_card")
		child.connect("chosen", self, "choose")
		choices.add_child(child)

func setup(progress: int, gold_amt: int, qty: int) -> void:
	chosen_action = null
	if gold_amt == 0:
		gold.hide()
	else:
		gold.show()
		gold.text = "+" + str(gold_amt)
		player.gold += gold_amt
		emit_signal("refresh_player", false)
	finished.text = "Skip Reward"
	var actions = new_picker(progress, qty)
	actions.shuffle()
	for child in choices.get_children():
		if child.get_index() >= qty:
			child.hide()
		elif actions.front() == "":
			child.hide()
		else:
			child.show()
			var action = load(actions.pop_front())
			child.initialize(action, player)
		child.chosen = false

func new_picker(progress: int, qty: int, other_classes: = false) -> Array:
	#warning-ignore:integer_division
	var level = min((1 + progress / 2) as int, 4)
	var loot_list = []
	var pick1 = loot1.duplicate(true)
	pick1.shuffle()
	var pick2 = loot2.duplicate(true)
	pick2.shuffle()
	var pick3 = loot3.duplicate(true)
	pick3.shuffle()
	var pick4 = loot4.duplicate(true)
	pick4.shuffle()

	for i in range(qty):
		var uncommon = 1.25
		var rare = 1.75
		var rand = randf()
		var chance = 0.15 * i
		var roll = rand + chance + level / 5.0
		var rank = 2
		if roll >= rare: rank = 4
		elif roll >= uncommon: rank = 3
		if rank == 4:
			if pick4.size() > 0:
				loot_list.append(pick4.pop_front())
			else: rank -= 1
		if rank == 3:
			if pick3.size() > 0:
				loot_list.append(pick3.pop_front())
			else: rank -= 1
		if rank == 2:
			if pick2.size() > 0:
				loot_list.append(pick2.pop_front())
			else: rank -= 1
		if rank == 1:
			if pick1.size() > 0:
				loot_list.append(pick1.pop_front())
			else: rank -= 1
		if rank == 0:
			loot_list.append("")
	return loot_list

func remove_loot(item: String) -> void:
	item = item.to_lower()
	item = item.replace(" ", "_")
	item += ".tres"
	var path = "res://src/actions/" + player.name.to_lower() + "/"
	if loot1.has(path + "1/" + item):
		loot1.remove(loot1.find(path + "1/" + item))
		return
	if loot2.has(path + "2/" + item):
		loot2.remove(loot2.find(path + "2/" + item))
		return
	if loot3.has(path + "3/" + item):
		loot3.remove(loot3.find(path + "3/" + item))
		return
	if loot4.has(path + "4/" + item):
		loot4.remove(loot4.find(path + "4/" + item))
		return

func get_loot(rank: int, other_classes: = false) -> Array:
	var list = []
	var path = "res://src/actions/" + player.name.to_lower() + "/" + str(rank) + "/"
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()

	for loot in files:
		list.append(path + loot)

	return list

func get_other_loot(rank: int) -> Array:
	return get_loot(rank, true)

func _on_Finished_pressed():
	if chosen_action != null:
		AudioController.confirm()
		if chosen_action.action_type == Action.ActionType.PERMANENT:
			if chosen_action.damage_type == Action.DamageType.HP:
				player.max_hp += chosen_action.damage
				player.hp += chosen_action.damage
			elif chosen_action.damage_type == Action.DamageType.MP:
				player.initial_mp += chosen_action.damage
			player.update_perk_bonuses()
		else:
			player.actions.append(chosen_action)
			player.actions.sort()
	else: AudioController.click()
	emit_signal("looting_finished")

func choose(choice: ActionChoice) -> void:
	for child in choices.get_children():
		if child == choice:
			child.chosen = !child.chosen
			if child.chosen:
				AudioController.click()
				finished.text = "Take Reward"
				chosen_action = child.action
			else:
				AudioController.back()
				chosen_action = null
				finished.text = "Skip Reward"
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
