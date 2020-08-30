extends Node2D
class_name Enemy

var FloatingText = preload("res://assets/animations/FloatingText.tscn")

signal used_action(action)
signal ended_turn
signal block_input
signal died

onready var animationPlayer: = $Enemy/AnimationPlayer
onready var hp_value = $Enemy/HP/Value
onready var hp_percent = $Enemy/HP/TextureProgress
onready var attack_icon = $Enemy/Attack/Sprite
onready var attack_value = $Enemy/Attack/RichTextLabel
onready var hp_panel = $Enemy/HP
onready var atk_panel = $Enemy/Attack

var actor: Actor
var action_to_use: Action
var died: bool setget , get_died

var hp: int setget set_hp
#var ac: int setget set_ac
#var mp: int setget set_mp
#var ap: int setget set_ap

func initialize(_actor: Actor) -> void:
	actor = _actor
	animationPlayer.play("Idle")
	hp_percent.max_value = actor.max_hp
	self.hp = actor.max_hp
	$Enemy/Sprite.position = Vector2.ZERO
	$Enemy/Sprite.modulate.a = 1
	$Enemy/Level.text = "Lv." + str(actor.level)
	hp_panel.show()
	atk_panel.show()
	update_atk_panel()

func take_hit(action: Action, damage: int, crit: bool) -> void:
	var floating_text = FloatingText.instance()
	floating_text.initialize(damage, crit)
	add_child(floating_text)
	self.hp -= damage
	if self.died:
		emit_signal("block_input")
		hp_panel.hide()
		atk_panel.hide()
		animationPlayer.play("Died")
		yield(animationPlayer, "animation_finished")
		emit_signal("died")
	else:
		animationPlayer.play("Hit")
		yield(animationPlayer, "animation_finished")
		animationPlayer.play("Idle")

func act() -> void:
	animationPlayer.play("Attack")
	yield(animationPlayer, "animation_finished")
	animationPlayer.play("Idle")
	update_atk_panel()
	emit_signal("ended_turn")

func inflict_hit() -> void:
	emit_signal("used_action", action_to_use)

func update_atk_panel() -> void:
	var rand = randi() % actor.actions.size()
	action_to_use = actor.actions[rand]
	var dmg_text = str(action_to_use.damage)
	if action_to_use.hits > 1:
		dmg_text += "x" + str(action_to_use.hits)
	attack_value.bbcode_text	 = dmg_text
	attack_icon.frame = action_to_use.frame_id

# SETTERS ###########################################

func set_hp(value: int) -> void:
	value = clamp(value, 0, actor.max_hp)
	hp = value
	var zeros = 3 - str(value).length()
	var cur = str(value).pad_zeros(3)
	var cur_sub = cur.substr(0, zeros)
	zeros = 3 - str(actor.max_hp).length()
	cur = str(actor.max_hp).pad_zeros(3)
	var text = "[color=#22252522]" + cur_sub + "[/color]" + str(value)
	hp_value.bbcode_text = text
	hp_percent.value = hp

func get_died() -> bool:
	return hp == 0

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
