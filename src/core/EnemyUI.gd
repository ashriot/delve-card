extends Node2D
class_name Enemy

var FloatingText = preload("res://assets/animations/FloatingText.tscn")
var EBuffUI = preload("res://src/battle/EBuffUI.tscn")
var EDebuffUI = preload("res://src/battle/EDebuffUI.tscn")
var Burn = preload("res://src/actions/debuffs/burn_action.tres")
var Mend = preload("res://src/actions/buffs/mend_action.tres")

signal used_action(action)
signal ended_turn
signal block_input
signal died

onready var sprite: = $Enemy/Sprite
onready var animationPlayer: = $Enemy/AnimationPlayer
onready var hp_value = $Enemy/HP/Value
onready var hp_percent = $Enemy/HP/TextureProgress
onready var ac_panel = $Enemy/AC
onready var ac_value = $Enemy/AC/Value
onready var mp_panel = $Enemy/MP
onready var mp_value = $Enemy/MP/Value
onready var attack_icon = $Enemy/Attack/Sprite
onready var attack_value = $Enemy/Attack/RichTextLabel
onready var hp_panel = $Enemy/HP
onready var atk_panel = $Enemy/Attack

onready var buff_bar = $Enemy/BuffBar
onready var debuff_bar = $Enemy/DebuffBar

var buffs: Dictionary
var debuffs: Dictionary

var vars: Dictionary

var actor: EnemyActor
var action_to_use: Action
var dead: bool setget , get_dead

var added_damage: = 0
var damage_multiplier = 0.0 as float
var damage_reduction = 0.0 as float

var player: Player

var intent: String

var hp: int setget set_hp
var ac: int setget set_ac
var mp: int setget set_mp
#var ap: int setget set_ap

func initialize(_actor: EnemyActor, _player: Player) -> void:
	actor = _actor
	player = _player
	set_vars()
	sprite.texture = actor.texture
	animationPlayer.play("Idle")
	hp_percent.max_value = actor.max_hp
	self.hp = actor.max_hp
	self.ac = actor.initial_ac
	self.mp = actor.initial_mp
	if mp == 0:
		mp_panel.hide()
	else:
		mp_panel.show()
#	self.hp = 1
#	self.ac = 0
	$Enemy/Sprite.position = Vector2.ZERO
	$Enemy/Sprite.modulate.a = 1
	added_damage = 0
	damage_multiplier = 0.0
	damage_reduction = 0.0
	buffs.clear()
	for child in buff_bar.get_children():
		child.queue_free()
	hp_panel.show()
	atk_panel.show()
	buff_bar.show()
	debuff_bar.show()
	update_atk_panel()
	debuffs.clear()
	for child in debuff_bar.get_children():
		child.queue_free()

func act() -> void:
	if action_to_use.cost_type == Action.DamageType.MP:
		self.mp -= action_to_use.cost
	if debuffs.size() > 0:
		if debuffs.has("Burn"):
			AudioController.play_sfx("fire")
			take_hit(Burn, debuffs["Burn"].stacks, false)
			reduce_debuff("Burn")
			yield(get_tree().create_timer(0.8), "timeout")
	if self.dead:
		print("dead, ended turn")
		emit_signal("ended_turn")
		return
	if intent == "Attack":
		animationPlayer.play(intent + str(action_to_use.hits))
	else:
		animationPlayer.play("Cast")

func inflict_hit() -> void:
	if action_to_use.target_type == Action.TargetType.OPPONENT:
		emit_signal("used_action", action_to_use)
	else:
		take_effect(action_to_use, action_to_use.damage)

func action_done() -> void:
	animationPlayer.play("Idle")
	if buffs.size() > 0:
		if buffs.has("Mend"):
			AudioController.play_sfx("heal")
			take_effect(Mend, buffs["Mend"].stacks)
			yield(get_tree().create_timer(0.8), "timeout")
	reduce_debuffs()
	reduce_buffs()
	update_atk_panel()
	print("EnemyUI 'ended_turn' signal fired.")
	emit_signal("ended_turn")

func take_effect(action: Action, damage: int) -> void:
	if action.extra_action != null:
		action.extra_action.execute(self)
	var amount = damage
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
		var pos = Vector2(self.position.x, self.position.y + rand_range(-8, 8))
		floating_text.position = pos
		get_parent().add_child(floating_text)

func take_hit(action: Action, damage: int, crit: bool) -> void:
	if self.dead: return
	if action.name == "Executioner Axe":
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
			if not action.penetrate:
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
		if animationPlayer.current_animation == "Idle":
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

func gain_buff(buff: Buff, amt: int) -> void:
	var floating_text = FloatingText.instance()
	floating_text.display_text("+" + buff.name)
	get_parent().add_child(floating_text)
	floating_text.position = Vector2(54, 37)
	for b in buffs.keys():
		if b == buff.name:
			buffs[b].stacks += amt
			if buff.name == "Power":
				added_damage = buffs[buff.name].stacks
				update_data()
			return
	var buffUI = EBuffUI.instance()
	buffUI.initialize(buff, amt)
	buff_bar.add_child(buffUI)
	buffs[buff.name] = buffUI
	if buff.name == "Power":
		added_damage = buffs[buff.name].stacks
		update_data()
	buffUI.connect("remove_buff", self, "remove_buff")
	buffUI.connect("show_card", self, "show_buff_card")
	buffUI.connect("hide_card", self, "hide_buff_card")

func reduce_buffs() -> void:
	if buffs.size() > 0:
		for buff in buffs:
			reduce_buff(buff)

func reduce_buff(buff_name: String) -> void:
	for child in buff_bar.get_children():
		if child.buff_name == buff_name:
			if buff_name == "Power":
				added_damage -= 1
			child.stacks -= 1

func remove_buff(buff_name: String) -> void:
	var child = buffs[buff_name]
	buff_bar.remove_child(child)
	buffs.erase(buff_name)
	child.queue_free()

func has_buff(title: String) -> bool:
	return buffs.has(title)

func gain_debuff(debuff: Buff, qty: int) -> void:
	var floating_text = FloatingText.instance()
	floating_text.display_text("+" + debuff.name)
	floating_text.position = Vector2(40, 37)
	get_parent().add_child(floating_text)
	for d in debuffs.keys():
		if d == debuff.name:
			debuffs[d].stacks += qty
			return
	var debuffUI = EDebuffUI.instance()
	debuffUI.initialize(debuff, qty)
	debuff_bar.add_child(debuffUI)
	debuffs[debuff.name] = debuffUI
	if debuff.name == "Weak":
		damage_multiplier -= 0.25
	elif debuff.name == "Sunder":
		damage_reduction -= 0.5
	debuffUI.connect("remove_debuff", self, "remove_debuff")
#	debuffUI.connect("show_card", self, "show_buff_card")
#	debuffUI.connect("hide_card", self, "hide_buff_card")
	update_data()

func get_debuff_stacks(title: String) -> int:
	for child in debuff_bar.get_children():
		if child.debuff_name == title:
			return child.stacks
	return 0

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
	update_data()

func remove_debuff(debuff_name: String) -> void:
	if debuff_name == "Weak":
		damage_multiplier += 0.25
	elif debuff_name == "Sunder":
		damage_reduction += 0.5
	var child = debuffs[debuff_name]
	debuff_bar.remove_child(child)
	debuffs.erase(debuff_name)
	child.queue_free()

func update_atk_panel() -> void:

	action_to_use = enemy_ai()
	attack_icon.frame = action_to_use.frame_id
	intent = "Attack" if action_to_use.action_type == Action.ActionType.WEAPON \
		else "Skill"
	update_data()

func update_data() -> void:
	var bonus = 0.0
	var damage = float(action_to_use.damage)
	if !action_to_use.healing:
		bonus = float(action_to_use.damage) * (damage_multiplier) + added_damage
		damage *= (1 - player.damage_reduction)
	var dmg = damage + bonus
	var dmg_text: String
	if action_to_use.healing:
		dmg_text = "+"
	dmg_text += str(int(dmg))
	if action_to_use.hits > 1:
		dmg_text += "x" + str(action_to_use.hits)
	if action_to_use.damage == 0:
		dmg_text = ""
	attack_value.bbcode_text = dmg_text

func get_intent() -> String:
	return intent

func enemy_ai() -> Action:
	if actor.name == "bear": return bear()
	elif actor.name == "devil": return devil()
	elif actor.name == "slime": return slime()
	else:
		var rand = randi() % actor.actions.size()
		print("RAND: ", rand, "/", actor.actions.size())
		return actor.actions[rand]

func bear() -> Action:
	var action = null
	vars.turns += 1
	if is_injured(0.5) and !vars.bloodied:
		vars.bloodied = true
		action = actor.actions[4]		# Gird
	elif is_injured(0.25) and !vars.dying:
		vars.dying = true
		action = actor.actions[5]		# Hibernate
	elif vars.turns % 5 == 1:
		action = actor.actions[0]		# Roar
	elif randf() < 0.9 and vars.maul_uses < 3:
		if is_injured(0.5): action = actor.actions[3]
		else: action = actor.actions[2]	# 2x/3x
	else:
		if is_injured(0.5): action = actor.actions[2]
		else: action = actor.actions[1]	# 1x/2x
	if action.name == "Attack2":
		vars.maul_uses += 1
	else:
		vars.maul_uses = 0
	return action

func devil() -> Action:
	var action = actor.actions[0]
	if mp > 4:
		if !vars.shield_used:
			vars.shield_used = true
			action = actor.actions[2]	# Flame Shield
		else:
			vars.shield_used = false
			action = actor.actions[1]	# Fatigue
	return action

func slime() -> Action:
	var action = actor.actions[0]
	if randf() < 0.5:
		if !buffs.has("Mend"):
			action = actor.actions[1]
		else:
			action = actor.actions[2]
	return action

func set_vars() -> void:
	vars.clear()
	if actor.name == "bear":
		vars = {
			"bloodied": false,
			"10%": false,
			"maul_uses": 0,
			"turns": 0,
			"dying": false
		}
	elif actor.name == "devil":
		vars = {
			"shield_used": false
		}

func is_injured(threshold: float) -> bool:
	return (float(hp) / float(actor.max_hp) <= threshold)

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
	if vars.has("bloodied"):
		if !vars.bloodied and is_injured(0.5):
			update_atk_panel()
	if vars.has("dying"):
		if !vars.dying and is_injured(0.25):
			update_atk_panel()

func set_ac(value: int) -> void:
	value = max(value, 0)
	ac = value
	if ac == 0:
		ac_panel.hide()
	else:
		ac_panel.show()
	var zeros = 3 - str(value).length()
	var cur = str(value).pad_zeros(3)
	var cur_sub = cur.substr(0, zeros)
	var text = "[color=#22252522]" + cur_sub + "[/color]" + str(value)
	ac_value.bbcode_text = text

func set_mp(value: int) -> void:
	value = max(value, 0)
	mp = value
	var zeros = 3 - str(value).length()
	var cur = str(value).pad_zeros(3)
	var cur_sub = cur.substr(0, zeros)
	var text = "[color=#22252522]" + cur_sub + "[/color]" + str(value)
	mp_value.bbcode_text = text

func get_dead() -> bool:
	return hp == 0
