extends Node2D
class_name Enemy

var FloatingText = preload("res://assets/animations/FloatingText.tscn")

signal used_action(action)
signal ended_turn

onready var animationPlayer: = $Enemy/AnimationPlayer
onready var hp_value = $Enemy/HP/Value
onready var hp_percent = $Enemy/HP/TextureProgress

var actor: Actor
var action: Action

var hp: int setget set_hp
#var ac: int setget set_ac
#var mp: int setget set_mp
#var ap: int setget set_ap

func initialize(_actor: Actor) -> void:
	actor = _actor
	animationPlayer.play("Idle")
	hp_percent.max_value = actor.max_hp
	self.hp = actor.max_hp
#	self.ac = actor.initial_ac
#	self.mp = actor.initial_mp
#	self.ap = actor.max_ap

func take_hit(damage) -> void:
	print("taking ", damage, " damage")
	var crit = 0
	var floating_text = FloatingText.instance()
	floating_text.initialize(damage, crit == 1)
	add_child(floating_text)
	self.hp -= damage
	animationPlayer.play("Hit")
	yield(animationPlayer, "animation_finished")
	animationPlayer.play("Idle")

func act() -> void:
	action = actor.actions.front()
	animationPlayer.play("Attack")
	yield(animationPlayer, "animation_finished")
	emit_signal("ended_turn")

func inflict_hit() -> void:
	emit_signal("used_action", action)

# SETTERS ###########################################

func set_hp(value: int) -> void:
	hp = value
	var zeros = 3 - str(value).length()
	var cur = str(value).pad_zeros(3)
	var cur_sub = cur.substr(0, zeros)
	zeros = 3 - str(actor.max_hp).length()
	cur = str(actor.max_hp).pad_zeros(3)
	var text = "[color=#22252522]" + cur_sub + "[/color]" + str(value)
	hp_value.bbcode_text = text
	hp_percent.value = hp

#func set_ac(value: int) -> void:
#	ac = value
#	var zeros = 3 - str(value).length()
#	var cur = str(value).pad_zeros(3)
#	var cur_sub = cur.substr(0, zeros)
#	var text = "[color=#22252522]" + cur_sub + "[/color]" + str(value)
#	ac_value.bbcode_text = text

#func set_mp(value: int) -> void:
#	mp = value
#	var zeros = 3 - str(value).length()
#	var cur = str(value).pad_zeros(3)
#	var cur_sub = cur.substr(0, zeros)
#	var text = "[color=#22252522]" + cur_sub + "[/color]" + str(value)
#	mp_value.bbcode_text = text
#
#func set_ap(value: int) -> void:
#	print("NEED TO HOOK UP AP VALUES!!!!!!")
#	pass
