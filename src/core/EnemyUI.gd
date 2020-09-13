extends Node2D
class_name Enemy

var FloatingText = preload("res://assets/animations/FloatingText.tscn")
var EDebuffUI = preload("res://src/battle/EDebuffUI.tscn")
var Burn = preload("res://src/actions/debuffs/burn_action.tres")

signal used_action(action)
signal ended_turn
signal block_input
signal died

onready var animationPlayer: = $Enemy/AnimationPlayer
onready var hp_value = $Enemy/HP/Value
onready var hp_percent = $Enemy/HP/TextureProgress
onready var ac_panel = $Enemy/AC
onready var ac_value = $Enemy/AC/Value
onready var attack_icon = $Enemy/Attack/Sprite
onready var attack_value = $Enemy/Attack/RichTextLabel
onready var hp_panel = $Enemy/HP
onready var atk_panel = $Enemy/Attack

onready var buff_bar = $Enemy/BuffBar
onready var debuff_bar = $Enemy/DebuffBar

var buffs: Dictionary
var debuffs: Dictionary

var actor: Actor
var action_to_use: Action
var dead: bool setget , get_dead

var damage_multiplier = 0.0 as float
var damage_reduction = 0.0 as float

var intent: String

var hp: int setget set_hp
var ac: int setget set_ac
#var mp: int setget set_mp
#var ap: int setget set_ap

func initialize(_actor: Actor) -> void:
	actor = _actor
	animationPlayer.play("Idle")
	hp_percent.max_value = actor.max_hp
	self.hp = actor.max_hp
	self.ac = actor.initial_ac
	$Enemy/Sprite.position = Vector2.ZERO
	$Enemy/Sprite.modulate.a = 1
	$Enemy/Level.text = "Lv." + str(actor.level)
	damage_multiplier = 0
	damage_reduction = 0
	hp_panel.show()
	atk_panel.show()
	buff_bar.show()
	debuff_bar.show()
	update_atk_panel()
	debuffs.clear()
	for child in debuff_bar.get_children():
		child.queue_free()

func act() -> void:
	if debuffs.size() > 0:
		if debuffs.has("Burn"):
			AudioController.play_sfx("fire")
			take_hit(Burn, debuffs["Burn"].stacks, false)
			reduce_debuff("Burn")
			yield(get_tree().create_timer(0.8), "timeout")
	if self.dead:
		emit_signal("ended_turn")
		return
	if intent == "Attack":
		animationPlayer.play("Attack")
	else:
		animationPlayer.play("Cast")
	yield(animationPlayer, "animation_finished")
	animationPlayer.play("Idle")
	update_atk_panel()
	reduce_debuffs()
	emit_signal("ended_turn")

func inflict_hit() -> void:
	if action_to_use.target_type == Action.TargetType.OPPONENT:
		emit_signal("used_action", action_to_use)
	else:
		take_effect(action_to_use)

func take_effect(action: Action) -> void:
	var amount = action.damage
	if action.healing:
		var type = action.damage_type
		var postfix = ""
		var floating_text = FloatingText.instance()
		if type == Action.DamageType.HP:
			self.hp += amount
			postfix = " HP"
		if type == Action.DamageType.AC:
			self.ac += amount
			postfix = " AC"
		if type == Action.DamageType.AP:
			self.ap += amount
		if type == Action.DamageType.MP:
			self.mp += amount
		var text = "+" + str(amount) + postfix
		floating_text.display_text(text)
		floating_text.position = self.position
		get_parent().add_child(floating_text)

func take_hit(action: Action, damage: int, crit: bool) -> void:
	if action.name == "Executioner":
		if hp < 11:
			self.hp = 0
	else:
		if action.name == "Fireball":
			if debuffs.has("Burn"):
				damage *= 2
		damage *= (1 - damage_reduction)
		if damage > 0:
			var floating_text = FloatingText.instance()
			floating_text.initialize(damage, crit)
			add_child(floating_text)
			if ac > 0:
				if ac > damage:
					self.ac -= damage
					damage = 0
				else:
					damage -= ac
					self.ac = 0
			self.hp -= damage
	if self.dead:
		die()
	else:
		animationPlayer.play("Hit")
		yield(animationPlayer, "animation_finished")
		animationPlayer.play("Idle")

func die() -> void:
	emit_signal("block_input")
	hp_panel.hide()
	atk_panel.hide()
	buff_bar.hide()
	debuff_bar.hide()
	animationPlayer.play("Died")
	yield(animationPlayer, "animation_finished")
	emit_signal("died")

func gain_debuff(debuff: Buff, qty: int) -> void:
	var floating_text = FloatingText.instance()
	floating_text.display_text("+" + debuff.name)
	floating_text.position = Vector2(54, 37)
	get_parent().add_child(floating_text)
	for d in debuffs.keys():
		if d == debuff.name:
			debuffs[d].stacks += qty
			return
	var debuffUI = EDebuffUI.instance()
	debuffUI.initialize(debuff, qty)
	debuff_bar.add_child(debuffUI)
	debuffs[debuff.name] = debuffUI
	if debuff.name == "Burn":
		pass
	elif debuff.name == "Weak":
		damage_multiplier -= 0.25
	elif debuff.name == "Sunder":
		damage_reduction -= 0.25
	debuffUI.connect("remove_debuff", self, "remove_debuff")
#	debuffUI.connect("show_card", self, "show_buff_card")
#	debuffUI.connect("hide_card", self, "hide_buff_card")
	update_atk_value()

func has_debuff(title: String) -> bool:
	return debuffs.has(title)

func reduce_debuffs() -> void:
	for child in debuff_bar.get_children():
		if child.fades_per_turn:
			reduce_debuff(child.debuff_name)

func reduce_debuff(debuff_name: String) -> void:
	for child in debuff_bar.get_children():
		if child.debuff_name == debuff_name:
			child.stacks -= 1
	update_atk_value()

func remove_debuff(debuff_name: String) -> void:
	if debuff_name == "Weak":
		damage_multiplier += 0.25
	elif debuff_name == "Sunder":
		damage_reduction += 0.25
	var child = debuffs[debuff_name]
	debuff_bar.remove_child(child)
	debuffs.erase(debuff_name)
	child.queue_free()

func update_atk_panel() -> void:
	var rand = randi() % actor.actions.size()
	action_to_use = actor.actions[rand]
	attack_icon.frame = action_to_use.frame_id
	intent = "Attack" if action_to_use.action_type == Action.ActionType.WEAPON \
		else "Skill"
	update_atk_value()

func update_atk_value() -> void:
	var dmg = float(action_to_use.damage) * (1 + damage_multiplier)
	var dmg_text: String
	if action_to_use.healing:
		dmg_text += "+"
	dmg_text += str(int(dmg))
	if action_to_use.hits > 1:
		dmg_text += "x" + str(action_to_use.hits)
	attack_value.bbcode_text	 = dmg_text

func get_intent() -> String:
	return intent

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

func set_ac(value: int) -> void:
	value = clamp(value, 0, actor.max_hp)
	ac = value
	if ac == 0:
		ac_panel.hide()
	else:
		ac_panel.show()
	var zeros = 3 - str(value).length()
	var cur = str(value).pad_zeros(3)
	var cur_sub = cur.substr(0, zeros)
	zeros = 3 - str(actor.max_hp).length()
	cur = str(actor.max_hp).pad_zeros(3)
	var text = "[color=#22252522]" + cur_sub + "[/color]" + str(value)
	ac_value.bbcode_text = text

func get_dead() -> bool:
	return hp == 0
