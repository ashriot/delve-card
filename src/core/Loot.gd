extends Node2D
class_name Loot

var _ActionChoice = preload("res://src/core/ActionChoice.tscn")

signal looting_finished

onready var playerUI = $Player
onready var hp_value = $Player/Player/Panel/HP/Value
onready var hp_percent = $Player/Player/Panel/HP/TextureProgress
onready var ac_value = $Player/Player/Panel/AC/Value
onready var mp_value = $Player/Player/Panel/MP/Value
onready var ap = $Player/Player/Panel/AP/Current
onready var deck_label = $Player/Deck/ColorRect/Label
onready var card = $Card
onready var choices = $Choices
onready var finished = $Finished
onready var gold = $Gold
onready var skip_progress = $Finished/TextureRect

var player: Actor
var chosen_action: Action

func initialize(_player: Actor) -> void:
	card.hide()
	player = _player
	deck_label.text = str(player.actions.size())
	
	for _i in range(3):
		var child = _ActionChoice.instance()
		child.connect("show_card", self, "_on_show_card")
		child.connect("hide_card", self, "_on_hide_card")
		child.connect("chosen", self, "choose")
		choices.add_child(child)

func setup(actions: Array) -> void:
	set_hp(player.hp)
	set_ac(player.initial_ac)
	set_mp(player.initial_mp)
	gold = str(player.gold)
	finished.text = "Skip Reward"
	actions.shuffle()
	for child in choices.get_children():
		child.chosen = false
		child.initialize(actions.pop_front(), player)

func set_hp(value) -> void:
	var zeros = 3 - str(value).length()
	var cur = str(value).pad_zeros(3)
	var cur_sub = cur.substr(0, zeros)
	zeros = 3 - str(player.max_hp).length()
	cur = str(player.max_hp).pad_zeros(3)
	var max_sub = cur.substr(0, zeros)
	var text = "[color=#22cac7b8]" + cur_sub + "[/color]" + str(value) \
		+ "/[color=#22cac7b8]" + max_sub + "[/color]" \
		+ str(player.max_hp)
	hp_value.bbcode_text = text
	hp_percent.max_value = player.max_hp
	hp_percent.value = value

func set_ac(value: int) -> void:
	var zeros = 3 - str(value).length()
	var cur = str(value).pad_zeros(3)
	var cur_sub = cur.substr(0, zeros)
	var text = "[color=#22cac7b8]" + cur_sub + "[/color]" + str(value)
	ac_value.bbcode_text = text

func set_mp(value: int) -> void:
	var zeros = 3 - str(value).length()
	var cur = str(value).pad_zeros(3)
	var cur_sub = cur.substr(0, zeros)
	var text = "[color=#22cac7b8]" + cur_sub + "[/color]" + str(value)
	mp_value.bbcode_text = text

func set_ap(value: int) -> void:
	ap = value
	ap.rect_size = Vector2(4 * ap, 7)

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
				finished.text = "Skip Reward"
		else:
			child.chosen = false

func _on_Finished_button_up():
	player.actions.append(chosen_action)
	player.actions.sort()
	AudioController.click()
	skip_progress.rect_size.x = 0
	emit_signal("looting_finished")

func _on_show_card(btn: ActionChoice) -> void:
	card.initialize(btn)

func _on_hide_card():
	card.close()
