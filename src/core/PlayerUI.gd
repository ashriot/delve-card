extends Node2D
class_name PlayerUI

var _FloatingText = preload("res://assets/animations/FloatingText.tscn")

signal open_deck(amt, type)
signal show_card(btn, amt)
signal hide_card

onready var portrait: = $Portrait
onready var hp_value = $Player/Panel/HP/Value
onready var hp_percent = $Player/Panel/HP/TextureProgress
onready var ac_value = $Player/Panel/AC/Value
onready var mp_value = $Player/Panel/MP/Value
onready var ap = $Player/Panel/AP/Current
onready var deck_label = $DeckButton/Label
onready var job_title = $JobTitle
onready var gold_label = $Gold/Label
onready var trinket_belt = $TrinketBelt
onready var item_belt = $ItemAnchor/ItemBelt
onready var animation_player = $Player/AnimationPlayer

var SAVE_KEY: String = "player"

var player: Actor
var profile_name: String

func initialize(game) -> void:
	player = game.player
	profile_name = game.core_data.profile_name
	connect("show_card", game, "show_card")
	connect("hide_card", game, "hide_card")
	connect("open_deck", game, "open_deck")
	job_title.text = profile_name + " the " + player.name
	portrait.frame = player.portrait_id
	item_belt.init_ui(self)
	trinket_belt.initialize(self)
	refresh()

func refresh() -> void:
	player.actions.sort()
	item_belt.init_ui(self)
	set_hp(player.hp)
	set_ac(player.initial_ac)
	set_ap(player.max_ap)
	set_mp(player.initial_mp)
	gold_label.text = comma_sep(player.gold)
	deck_label.text = str(player.actions.size())

func heal(amt: int, type: String) -> void:
	var ft = _FloatingText.instance()
	ft.initialize(amt, false)
	ft.position = Vector2(64, 164)
	get_parent().add_child(ft)
	if type == "HP":
		AudioController.play_sfx("heal")
		animation_player.play("Heal")
		player.hp += amt
		set_hp(player.hp)

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
	ap.rect_size = Vector2(5 * value, 7)

func show_card(btn, amt: int) -> void:
	emit_signal("show_card", btn, amt)

func hide_card() -> void:
	emit_signal("hide_card")

func comma_sep(n: int) -> String:
	var result := ""
	var i: int = abs(n)
	while i > 999:
		result = ",%03d%s" % [i % 1000, result]
		i /= 1000
	return "%s%s%s" % ["-" if n < 0 else "", i, result]

func _on_DeckButton_button_up():
	AudioController.click()
	emit_signal("open_deck")

func save(save_game: Resource) -> void:
	print("saving player data")
	save_game.data[SAVE_KEY] = {
		"player": player,
		"actions": player.actions,
		"potions": player.potions,
		"trinkets": player.trinkets,
		"max_hp": player.max_hp,
		"max_ap": player.max_ap,
		"initial_ac": player.initial_ac,
		"initial_mp": player.initial_mp,
		"gold": player.gold
	}

func load(save_game: Resource) -> void:
	print('loading player data')
	var data: Dictionary = save_game.data[SAVE_KEY]
	player = data["player"]
	player.actions = data["actions"]
