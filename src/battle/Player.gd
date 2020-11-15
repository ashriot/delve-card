extends Node2D
class_name Player

var FloatingText = preload("res://assets/animations/FloatingText.tscn")
var BuffUI = preload("res://src/battle/BuffUI.tscn")
var DebuffUI = preload("res://src/battle/DebuffUI.tscn")
var BuffCard = preload("res://src/battle/BuffCard.tscn")

signal add_to_deck(action_name, qty)
signal apply_debuff(debuff, qty)

onready var hp_value = $Player/Panel/HP/Value
onready var hp_percent = $Player/Panel/HP/TextureProgress
onready var ac_value = $Player/Panel/AC/Value
onready var mp_value = $Player/Panel/MP/Value

onready var buff_bar = $BuffBar
onready var debuff_bar = $DebuffBar

var hp: int setget set_hp
var ac: int setget set_ac
var mp: int setget set_mp
var ap: int setget set_ap
var dead: bool setget , get_dead

var added_damage: = 0
var weapon_multiplier: = 0.0
var damage_reduction: = 0.0

var actor: Actor
var buffs: Dictionary
var debuffs: Dictionary

func initialize(_actor: Actor) ->  void:
	assert(_actor is Actor)
	actor = _actor as Actor
	self.hp = actor.max_hp
	self.ac = actor.initial_ac
	self.mp = actor.initial_mp
	self.ap = actor.max_ap
	actor.actions.sort()
	$Player/Panel/AP/Max.rect_size = Vector2(5 * actor.max_ap, 7)

func reset() -> void:
	self.hp = actor.hp
	self.ap = actor.max_ap
	self.ac = actor.initial_ac
	self.mp = actor.initial_mp
	added_damage = 0
	weapon_multiplier = 0.0
	damage_reduction = 0.0
	buffs.clear()
	for child in buff_bar.get_children():
		child.queue_free()

func start_turn() -> void:
	self.ap = actor.max_ap
	for child in buff_bar.get_children():
		if child.fades_per_turn:
			reduce_buff(child.buff_name)
	for child in debuff_bar.get_children():
		if child.fades_per_turn:
			reduce_debuff(child.buff_name)

func take_hit(damage: int) -> void:
	var floating_text = FloatingText.instance()
	var miss = false
	if buffs.has("Dodge"):
		print("trying to dodge")
		miss = randf() < .5
	if miss:
		damage = 0
#	var blocked_dmg = 0
#	var hp_dmg = 0
	if buffs.has("Mage Armor"):
		if mp > damage:
			self.mp -= damage
			damage = 0
		else:
			damage -= mp
			self.mp = 0
	if ac > 0:
		if ac > damage:
			self.ac -= damage
#			blocked_dmg = damage
			damage = 0
		else:
			damage -= ac
#			blocked_dmg = damage
			self.ac = 0
	self.hp -= damage
#	hp_dmg = damage
	if miss:
		AudioController.play_sfx("miss")
		floating_text.display_text("Miss!")
	else:
		floating_text.initialize(damage, false)
		AudioController.play_sfx("hit")
		$AnimationPlayer.play("Shake")
	floating_text.position = Vector2(58, 70)
	get_parent().add_child(floating_text)

func take_healing(amount: int, type: String) -> void:
	var x = 40
	var y = 68
	var floating_text = FloatingText.instance()
	if type == "HP":
		x = 50
		self.hp += amount
	if type == "AC":
		x = 70
		self.ac += amount
	if type == "ST":
		self.ap += amount
	if type == "MP":
		x = 70
		y = 74
		self.mp += amount
	var text = "+" + str(amount) + type
	floating_text.display_text(text)
	floating_text.position = Vector2(x, y)
	get_parent().add_child(floating_text)

func add_to_deck(action_name: String, qty: int) -> void:
	emit_signal("add_to_deck", action_name, qty)

func update_data() -> void:
	get_tree().call_group("action_button", "update_data")

func gain_buff(buff: Buff, amt: int) -> void:
	var floating_text = FloatingText.instance()
	floating_text.display_text("+" + buff.name)
	floating_text.position = Vector2(54, 78)
	get_parent().add_child(floating_text)
	for b in buffs.keys():
		if b == buff.name:
			buffs[b].stacks += amt
			if buff.name == "Power":
				added_damage = buffs[buff.name].stacks
				update_data()
			return
	var buffUI = BuffUI.instance()
	buffUI.initialize(buff, amt)
	buff_bar.add_child(buffUI)
	buffs[buff.name] = buffUI
	if buff.name == "Power":
		added_damage = buffs[buff.name].stacks
		update_data()
	buffUI.connect("remove_buff", self, "remove_buff")
	buffUI.connect("show_card", self, "show_buff_card")
	buffUI.connect("hide_card", self, "hide_buff_card")

func reduce_buff(buff_name: String) -> void:
	for child in buff_bar.get_children():
		if child.buff_name == buff_name:
			if buff_name == "Power":
				added_damage -= 1
				get_tree().call_group("action_button", "update_data")
			child.stacks -= 1

func remove_buff(buff_name: String) -> void:
	var child = buffs[buff_name]
	buff_bar.remove_child(child)
	buffs.erase(buff_name)
	child.queue_free()

func has_buff(buff_name: String) -> bool:
	return buffs.has(buff_name)

func apply_debuff(debuff: Buff, qty: int) -> void:
	emit_signal("apply_debuff", debuff, qty)

func gain_debuff(debuff: Buff, qty: int) -> void:
	var floating_text = FloatingText.instance()
	floating_text.display_text("+" + debuff.name)
	floating_text.position = Vector2(54, 74)
	get_parent().add_child(floating_text)
	for d in debuffs.keys():
		if d == debuff.name:
			debuffs[d].stacks += qty
			return
	var debuffUI = DebuffUI.instance()
	debuffUI.initialize(debuff, qty)
	debuff_bar.add_child(debuffUI)
	debuffs[debuff.name] = debuffUI
	if debuff.name == "Burn":
		pass
	elif debuff.name == "Weak":
		weapon_multiplier -= 0.25
	elif debuff.name == "Sunder":
		damage_reduction -= 0.25
	debuffUI.connect("remove_buff", self, "remove_debuff")
#	debuffUI.connect("show_card", self, "show_buff_card")
#	debuffUI.connect("hide_card", self, "hide_buff_card")
	update_data()

func has_debuff(debuff_name: String) -> bool:
	return debuffs.has(debuff_name)

func reduce_debuffs() -> void:
	for child in debuff_bar.get_children():
		if child.fades_per_turn:
			reduce_debuff(child.debuff_name)

func reduce_debuff(debuff_name: String) -> void:
	for child in debuff_bar.get_children():
		if child.buff_name == debuff_name:
			child.stacks -= 1
	update_data()

func remove_debuff(debuff_name: String) -> void:
	if debuff_name == "Weak":
		weapon_multiplier += 0.25
	elif debuff_name == "Sunder":
		damage_reduction += 0.25
	var child = debuffs[debuff_name]
	debuff_bar.remove_child(child)
	debuffs.erase(debuff_name)
	child.queue_free()
	update_data()

func show_buff_card(buff: Buff) -> void:
	var buff_card = BuffCard.instance()
	buff_card.initialize(buff.name, buff.description)

func hide_buff_card() -> void:
	pass

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
	ap = value
	$Player/Panel/AP/Current.rect_size = Vector2(5 * ap, 7)

func get_dead() -> bool:
	return hp == 0
