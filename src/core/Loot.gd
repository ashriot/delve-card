extends Node2D
class_name Loot

var _ActionChoice = preload("res://src/core/ActionChoice.tscn")

signal looting_finished

onready var card = $Card
onready var choices = $Choices
onready var finished = $Finished
onready var skip_progress = $Finished/TextureRect

var player: Actor
var chosen_action: Action

var loot1: Array = []
var loot2: Array = []
var loot3: Array = []
var loot4: Array = []

func initialize(_player: Actor) -> void:
	player = _player
	loot1 = get_loot(1)
	loot2 = get_loot(2)
	loot3 = get_loot(3)
	loot4 = get_loot(4)
	card.hide()
	
	for _i in range(3):
		var child = _ActionChoice.instance()
		child.connect("show_card", self, "_on_show_card")
		child.connect("hide_card", self, "_on_hide_card")
		child.connect("chosen", self, "choose")
		choices.add_child(child)

func setup(progress: int) -> void:
	chosen_action = null
	finished.text = "Skip Reward"
	var actions = new_picker(progress)
	actions.shuffle()
	for child in choices.get_children():
		if actions.front() == "":
			child.hide()
		else:
			child.show()
			var action = load(actions.pop_front())
			child.initialize(action, player)
		child.chosen = false

func choose(choice: ActionChoice) -> void:
	for child in choices.get_children():
		if child == choice:
			child.chosen = !child.chosen
			if child.chosen:
				AudioController.click()
				finished.text = "Finished"
				chosen_action = child.action
			else:
				AudioController.back()
				chosen_action = null
				finished.text = "Skip Reward"
		else:
			child.chosen = false
	
func new_picker(progress: int) -> Array:
	var level = (2 + progress / 6) as int
	print(level)
	var loot_list = []
	var pick1 = loot1.duplicate(true)
	pick1.shuffle()
	var pick2 = loot2.duplicate(true)
	pick2.shuffle()
	var pick3 = loot3.duplicate(true)
	pick3.shuffle()
	var pick4 = loot4.duplicate(true)
	pick4.shuffle()
	
	for i in range(3):
		var common = min(level, 4)
		var rare = min(level + 1, 4)
		var rand = randf()
		var chance = 0.2 * i
		var rank = rare if rand < chance else common
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

func pick_loot(rank: int) -> String:
	var table: Array
	if rank == 1:
		table = loot1
	if rank == 2:
		table = loot2
	if rank == 3:
		table = loot3
	if rank == 4:
		table = loot4
	if table.size() == 0:
		return ""
	var rand = randi() % table.size()
	var item = table[rand]
	return item

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

func get_loot(rank: int) -> Array:
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

func _on_Finished_button_up():
	AudioController.click()
	if chosen_action != null:
		remove_loot(chosen_action.name)
		player.actions.append(chosen_action)
		player.actions.sort()
	skip_progress.rect_size.x = 0
	emit_signal("looting_finished")

func _on_show_card(btn: ActionChoice) -> void:
	var count = 0
	for a in player.actions:
		if a.name == btn.action.name:
			count += 1
	card.initialize(btn, count)

func _on_hide_card():
	card.close()
