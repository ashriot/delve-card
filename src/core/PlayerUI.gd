extends Node2D
class_name PlayerUI

signal show_card(btn, amt)
signal hide_card

onready var portrait: = $Portrait
onready var hp_value = $Player/Panel/HP/Value
onready var hp_percent = $Player/Panel/HP/TextureProgress
onready var ac_value = $Player/Panel/AC/Value
onready var mp_value = $Player/Panel/MP/Value
onready var ap = $Player/Panel/AP/Current
onready var deck_label = $DeckButton/Label
onready var deck = $Deck
onready var job_title = $JobTitle
onready var gold_label = $Gold/Label

var player: Actor

func initialize(_player: Actor) -> void:
	player = _player
	deck.initialize(player)
	deck.connect("show_card", self, "show_card")
	deck.connect("hide_card", self, "hide_card")
	job_title.text = player.name
	portrait.frame = player.portrait_id
	player.hp = player.max_hp
	refresh()

func refresh() -> void:
	set_hp(player.hp)
	set_ac(player.initial_ac)
	set_ap(player.max_ap)
	set_mp(player.initial_mp)
	gold_label.text = comma_sep(player.gold)
	deck_label.text = str(player.actions.size())
	deck.refresh(0)

func open_deck(selection_amt: int, type: String) -> void:
	print("Opening ", type)
	if type == "Upgrade":
		deck.upgrade(selection_amt)
	elif type == "Destroy":
		deck.destroy(selection_amt)
	deck.refresh(selection_amt)
	deck.show()

func comma_sep(n: int) -> String:
	var result := ""
	var i: int = abs(n)
	while i > 999:
		result = ",%03d%s" % [i % 1000, result]
		i /= 1000
	return "%s%s%s" % ["-" if n < 0 else "", i, result]

func heal(amt: int) -> void:
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

func _on_DeckButton_button_up():
	AudioController.click()
	deck.show()
