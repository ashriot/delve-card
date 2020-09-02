extends Node2D
class_name Player

var FloatingText = preload("res://assets/animations/FloatingText.tscn")

signal add_to_deck(action_name, qty)

onready var hp_value = $Player/Panel/HP/Value
onready var hp_percent = $Player/Panel/HP/TextureProgress
onready var ac_value = $Player/Panel/AC/Value
onready var mp_value = $Player/Panel/MP/Value

var hp: int setget set_hp
var ac: int setget set_ac
var mp: int setget set_mp
var ap: int setget set_ap
var dead: bool setget , get_dead

var actor: Actor

func initialize(_actor: Actor) ->  void:
#	randomize()
	assert(_actor is Actor)
	actor = _actor as Actor
	self.hp = actor.max_hp
	self.ac = actor.initial_ac
	self.mp = actor.initial_mp
	self.ap = actor.max_ap
	actor.actions.sort()
	$Player/Panel/AP/Max.rect_size = Vector2(4 * actor.max_ap, 7)

func reset() -> void:
	self.hp = actor.hp
	self.ap = actor.max_ap
	self.ac = actor.initial_ac
	self.mp = actor.initial_mp

func set_deck_count(value: int) -> void:
	$Deck/ColorRect/Label.text = str(value)

func set_graveyard_count(value: int) -> void:
	$Graveyard/Label.text = str(value)

func start_turn() -> void:
	self.ap += 1

func take_hit(damage: int) -> void:
	var floating_text = FloatingText.instance()
	var blocked_dmg = 0
	var hp_dmg = 0
	if ac > 0:
		if ac > damage:
			self.ac -= damage
			blocked_dmg = damage
			damage = 0
		else:
			damage -= ac
			blocked_dmg = damage
			self.ac = 0
	self.hp -= damage
	hp_dmg = damage
	floating_text.initialize(damage, false)
	floating_text.position = Vector2(54, 67)
	get_parent().add_child(floating_text)
	$AnimationPlayer.play("Shake")

func take_healing(amount: int, type: String) -> void:
	var floating_text = FloatingText.instance()
	if type == "HP":
		self.hp += amount
	if type == "AC":
		self.ac += amount
	if type == "ST":
		self.ap += amount
	if type == "MP":
		self.mp += amount
	var text = "+" + str(amount) + type
	floating_text.display_text(text)
	floating_text.position = Vector2(54, 67)
	get_parent().add_child(floating_text)

func add_to_deck(action_name: String, qty: int) -> void:
	emit_signal("add_to_deck", action_name, qty)

# SETTERS ###########################################

func set_hp(value: int) -> void:
	value = clamp(value, 0, actor.max_hp)
	hp = value
	actor.hp = value
	var zeros = 3 - str(value).length()
	var cur = str(value).pad_zeros(3)
	var cur_sub = cur.substr(0, zeros)
	zeros = 3 - str(actor.max_hp).length()
	cur = str(actor.max_hp).pad_zeros(3)
	var max_sub = cur.substr(0, zeros)
	var text = "[color=#22cac7b8]" + cur_sub + "[/color]" + str(value) \
		+ "/[color=#22cac7b8]" + max_sub + "[/color]" \
		+ str(actor.max_hp)
	hp_value.bbcode_text = text
	hp_percent.max_value = actor.max_hp
	hp_percent.value = hp

func set_ac(value: int) -> void:
	ac = value
	var zeros = 3 - str(value).length()
	var cur = str(value).pad_zeros(3)
	var cur_sub = cur.substr(0, zeros)
	var text = "[color=#22cac7b8]" + cur_sub + "[/color]" + str(value)
	ac_value.bbcode_text = text

func set_mp(value: int) -> void:
	mp = value
	var zeros = 3 - str(value).length()
	var cur = str(value).pad_zeros(3)
	var cur_sub = cur.substr(0, zeros)
	var text = "[color=#22cac7b8]" + cur_sub + "[/color]" + str(value)
	mp_value.bbcode_text = text

func set_ap(value: int) -> void:
	ap = clamp(value, 0, actor.max_ap)
	$Player/Panel/AP/Current.rect_size = Vector2(4 * ap, 7)

func get_dead() -> bool:
	return hp == 0
