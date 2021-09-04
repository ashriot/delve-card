extends Control
class_name ActionButton

var FloatingText = preload("res://assets/animations/FloatingText.tscn")
var burn_debuff = preload("res://src/actions/debuffs/burn.tres")

signal inflict_hit
signal inflict_effect
signal anim_finished
signal action_finished(action_button)
signal button_pressed(button)
signal unblock(value)
signal discarded(action_button)
signal draw_cards(action, qty)

signal show_card(action_button)
signal hide_card

onready var button = $Button
onready var animationPlayer: = $AnimationPlayer
onready var timer: = $Timer
onready var emphasis: = $Button/Emphasis

var actions = null
var action: Action
var player: Player
var enemy: Enemy
var played: = true

var hp_cost: int
var ap_cost: int setget set_ap_cost
var mp_cost: int
var mp_spent: int
var ap_spent: int
#var damage: int
var hits: int

var added_damage: = 0 setget set_added_damage
var weapon_multiplier: = 0.0 setget set_weapon_multiplier
var spell_multiplier: = 0.0 setget set_spell_multiplier

var hovering: = false
var initialized: = false

func initialize(_actions, _action: Action, _player: Player, _enemy: Enemy) -> void:
	actions = _actions
	action = _action
	player = _player
	enemy = _enemy
	$Button/AP.hide()
	$Button/MP.hide()
	$Button/Emphasis.hide()
	$Button/Sprite.frame = action.frame_id
	$Button.text = action.name
	if action.cost_type == Action.DamageType.HP:
		hp_cost = action.cost
	elif action.cost_type == Action.DamageType.AP:
		ap_cost = action.cost
	elif action.cost_type == Action.DamageType.MP:
		mp_cost = action.cost
	hits = action.hits
	call_deferred("update_data")
	initialized = true

func show() -> void:
	$Button.modulate.a = 0
	AudioController.play_sfx("draw")
	animationPlayer.play("Draw")
	yield(animationPlayer, "animation_finished")
	played = false
	update_data()

func gain() -> void:
	modulate.a = 1
	$Button.modulate.a = 1
	$Button.rect_position = Vector2.ZERO

func discard(end_of_turn: bool) -> void:
	played = true
	AudioController.play_sfx("draw")
	if action.fade:
		animationPlayer.play("Drop")
	else:
		animationPlayer.play("Discard")
	yield(animationPlayer, "animation_finished")
	if !end_of_turn:
		if action.name == "Lucky Dice": emit_signal("draw_cards", action, action.drawX + 1)
		if action.name == "Lucky Knife":
			create_effect(enemy.global_position, "hit")
			yield(self, "inflict_hit")
			var crit_mod = 0
			if player.has_buff("Aim"): crit_mod = 0.5
			var crit = randf() < crit_mod + action.crit_chance
			enemy.take_hit(action, action.damage * 3, crit)
	emit_signal("discarded", self)

func update_data() -> void:
	emphasis.hide()
	modulate.a = 1.0
	get_action_hits()
	if action.action_type == Action.ActionType.INJURY and !played:
		modulate.a = 0.4
	if action.cost_type == Action.DamageType.AP and action.cost > 0:
		$Button/AP.rect_size = Vector2(5 * ap_cost, 7)
		$Button/AP.show()
		if ap_cost > player.ap and !played:
			modulate.a = 0.4
	elif action.cost_type == Action.DamageType.MP and action.cost > 0:
		var mp_cost_txt = mp_cost
		if action.name == "Shadow Bolt": mp_cost_txt = clamp(player.mp, 1, 15)
		if action.name == "Shadow Cloak": mp_cost_txt = clamp(player.mp, 1, 15)
# warning-ignore:integer_division
		if action.name == "Shadow Dance": mp_cost_txt = clamp(player.mp/mp_cost, 1, 20/mp_cost) * mp_cost
# warning-ignore:integer_division
		if action.name == "Mana Storm": mp_cost_txt = min(5, player.mp / action.cost) * action.cost
		$Button/MP.bbcode_text = " " + str(mp_cost_txt) + "MP"
		$Button/MP.show()
		if mp_cost > player.mp and !played:
			modulate.a = 0.4
	elif action.cost_type == Action.DamageType.HP and action.cost > 0:
		$Button/MP.bbcode_text = " -" + str(hp_cost) + "HP"
		$Button/MP.show()
		if hp_cost > player.hp and !played:
			modulate.a = 0.4
	var hit_text = "" if hits < 2 else ("x" + str(hits))
	if action.name == "Lightning Claws": hit_text += "x?"
	var prepend = "-"
	if action.damage_type == Action.DamageType.HP: prepend = ""
	var type = "dmg"
	if action.healing:
		type = "HP"
		prepend = "+"
	if action.damage_type == Action.DamageType.AC:
		type = "AC"
	elif action.damage_type == Action.DamageType.MP:
		type = "MP"
	elif action.damage_type == Action.DamageType.AP:
		type = "ST"
	var drown = "+"
	var damage = action.damage
	if action.name != "Drown": drown = ""
	if action.name == "Shadow Bolt": damage *= min(player.mp, 15)
	if action.name == "Shadow Cloak": damage *= min(player.mp, 15)
	if action.name == "Hidden Knife":
		if actions.hand_count == 1:
			damage *= 2
			emphasis.show()
	if first_striking() and action.first_strike:
		emphasis.show()
		if action.name == "Gleaming Knife": damage *= 2
	if player.has_buff("Dodge"):
		if action.name == "Keen Eye": emphasis.show()
		if action.name == "Secret Knife":
			emphasis.show()
			damage = action.damage * 2
	if enemy.has_debuff("Poison"):
		if action.name == "Snake Knife":
			emphasis.show()
	if enemy.has_debuff("Burn"):
		if action.name == "Ember Knife":
			emphasis.show()
	if action.name == "Brace": damage = player.get_buff_stacks("Dodge") * 5
	if action.name == "Mind Games": damage = player.get_buff_stacks("Dodge") * 4
	if action.name == "Sneak Attack": damage = player.get_buff_stacks("Dodge") * 3
	var multiplier = 1
	if action.action_type == Action.ActionType.WEAPON:
		multiplier += weapon_multiplier + player.weapon_multiplier
	if action.action_type == Action.ActionType.SPELL:
		multiplier += spell_multiplier + player.weapon_multiplier
	if action.target_type == Action.TargetType.OPPONENT:
		var bonus = 0
		if action.impact > 0:
			bonus += player.added_damage * (action.impact - 1)
		if enemy.has_debuff("Burn"):
			if action.name == "Fireball": bonus += 6
			if action.name == "Combust": bonus += 12
		damage = ((damage + bonus + player.added_damage + added_damage) * \
			(multiplier - enemy.damage_reduction)) as int
	var text = "[right]" + prepend + str(damage) + drown + hit_text + type
#	print(action.name, " damage: ", action.damage)
	if action.damage == 0:
		text = ""
	if action.name == "Brilliant Crystal":
		var mod = min(player.mp, 30)
		text = "[right]" + str(mod) + "MP"
	if action.name == "Armor Up":
		var mod = min(player.ac, 30)
	if action.name == "Shield Slam":
		var mod = player.ac
		text = "[right]" + str(mod) + "dmg"
	$Button/Damage.bbcode_text = text

func playable() -> bool:
	if action.action_type == Action.ActionType.INJURY:
		return false
	if ap_cost > player.ap:
		return false
	if mp_cost > player.mp:
		return false
	if hp_cost > player.hp:
		return false
	return true

func get_error() -> String:
	if action.action_type == Action.ActionType.INJURY:
		return "Cannot use!"
	if ap_cost > player.ap:
		return "Not Enough ST!"
	if mp_cost > player.mp:
		return "Not Enough MP!"
	if hp_cost > player.hp:
		return "Not Enough HP!"
	return "Something's missing!"

func play() -> void:
	mp_spent = mp_cost
	ap_spent = ap_cost
	if action.name == "Lightning Claws": ap_spent = player.ap
	emit_signal("hide_card")
	if !playable():
		display_error()
		return
	played = true
	emit_signal("button_pressed", self)
	if action.drop or action.fade or action.consume:
		animationPlayer.play("Drop")
	else:
		animationPlayer.play("Use")
	player.ap -= ap_spent
	if action.name == "Shadow Bolt": mp_spent = min(player.mp, 15)
	if action.name == "Shadow Cloak": mp_spent = min(player.mp, 15)
# warning-ignore:integer_division
# warning-ignore:integer_division
	if action.name == "Shadow Dance": mp_spent = min(player.mp/mp_cost, 20/mp_cost) * mp_cost
	if action.name == "Mana Storm": mp_spent = 0
	player.mp -= mp_spent
	player.hp -= hp_cost
	execute()

func finalize_execute() -> void:
	emit_signal("action_finished", self)

func display_error() -> void:
	var floating_text = FloatingText.instance()
	floating_text.display_text(get_error())
	floating_text.position = Vector2(54, 0)
	get_parent().add_child(floating_text)

func execute() -> void:
	if action.discard_random_x > 0:
		player.discard_random(action.discard_random_x)
		var qty = yield(player, "discarded_x")
		if qty < action.discard_random_x:
			call_deferred("finalize_execute")
			return
	var draw = action.drawX
# warning-ignore:integer_division
	if action.name == "Shadow Dance": draw *= mp_spent / action.cost
	elif action.name == "Take Aim": if first_striking(): draw += 1
	if player.has_buff("Dodge"):
		if action.name == "Keen Eye":
			player.reduce_buff("Dodge")
			draw += 1
	if draw > 0:
		emit_signal("draw_cards", action, draw)
	if action.target_type == Action.TargetType.OPPONENT:
		get_action_hits()
		var parried = false
		if player.has_buff("Parry"):
				if action.action_type == Action.ActionType.WEAPON:
					AudioController.play_sfx("gleam")
					player.reduce_buff("Parry")
					parried = true
		for hit in hits:
			if enemy.dead: break
			if action.name == "Mana Storm": player.mp -= action.cost
			var damage = action.damage
			if parried:
				player.take_healing(damage, "AC")
				damage = 0
			else:
				create_effect(enemy.global_position, "hit")
				yield(self, "inflict_hit")
			if action.name == "Conflagration":
				if enemy.has_debuff("Burn"):
					var stacks = enemy.get_debuff_stacks("Burn")
					enemy.gain_debuff(burn_debuff, ((stacks + 2) * 2) - stacks)
				else:
					enemy.gain_debuff(burn_debuff, 10)
			if action.name == "Dismantle": damage = enemy.ac
			if action.name == "Shield Slam":
				damage = player.ac
				player.ac /= 2
			if player.has_buff("Dodge"):
				var amt = player.get_buff_stacks("Dodge")
				if action.name == "Sneak Attack":
					damage = amt * 3
					player.remove_buff("Dodge")
				elif action.name == "Secret Knife":
					damage += action.damage
					player.reduce_buff("Dodge")
			if first_striking():
				if action.name == "Gleaming Knife": damage *= 2
			if damage > 0:
				var bonus = 0
				var roll = randf()
				var crit_mod = 0
				if action.impact > 0:
					bonus += player.added_damage * (action.impact - 1)
				if enemy.has_debuff("Burn"):
					if action.name == "Fireball": bonus += 6
					elif action.name == "Combust": bonus += 12
					elif action.name == "Ember Knife": crit_mod = 1
				if enemy.has_debuff("Poison"):
					if action.name == "Snake Knife": crit_mod = 1
				if player.has_buff("Aim"): crit_mod += 0.5
				var crit = roll < min(crit_mod + action.crit_chance, 1)
				if action.name == "Hidden Knife": if actions.hand_count == 0: damage *= 2
				if action.name == "Shadow Bolt": damage *= mp_spent
				if action.name == "Drown": damage += clamp(player.mp, 0, 30)
				damage += (bonus + player.added_damage + added_damage) * \
					(1 + weapon_multiplier + player.weapon_multiplier)
				damage *= (2 if crit else 1)
				if action.name == "Silver Claws" and crit:
					player.take_healing(1, "ST")
				damage *= (1 - enemy.damage_reduction)
				enemy.take_hit(action, damage, crit)
				var lifesteal = 0
				if player.has_buff("Lifesteal"): lifesteal += damage / 2
				if action.name == "Blood Claws": lifesteal += damage / 2
				if lifesteal > 0: player.take_healing(lifesteal, "HP")
				if action.name == "Calcify": player.take_healing(damage / 2, "AC")
				elif action.name == "Swift Knife": player.take_healing(2, "AC")
				elif action.name == "Rune Knife" or action.name == "Rune Claws":
					player.take_healing(damage, "MP")
			else: enemy.shake()
			if action.extra_action != null:
				if action.name == "Offensive Tactics":
					if enemy.get_intent() == "Attack":
						action.extra_action.execute(player)
				else:
					action.extra_action.execute(player)
			if !enemy.dead:
				emit_signal("unblock", false)
			if hits > 1:
				if hit == (hits -1):
					yield(self, "anim_finished")
				else:
					yield(get_tree().create_timer(0.1), "timeout")
		if player.has_buff("Lifesteal") and action.damage > 0:
			player.reduce_buff("Lifesteal")
		if player.has_buff("Aim") and action.damage > 0:
			player.reduce_buff("Aim")
		if player.has_buff("Hide"): player.reduce_buff("Hide")
		finalize_execute()
	else:
		create_effect(player.global_position, "effect")
		yield(self, "inflict_effect")
		emit_signal("unblock", false)
		if action.extra_action != null:
			action.extra_action.execute(player)
		var damage = action.damage
		if action.name == "Shadow Cloak": damage *= mp_spent
		if action.name == "Brilliant Crystal": damage = min(player.mp, 30)
		if action.name == "Armor Up": damage = min(player.ac, 30)
		if first_striking():
			if action.name == "Steal Gold":
				damage = randi() % 6 + 5
				AudioController.confirm()
				player.take_healing(damage, "GP")
				damage = 0
		if player.has_buff("Dodge"):
			var amt = player.get_buff_stacks("Dodge")
			if action.name == "Brace":
				damage = amt * 5
				player.remove_buff("Dodge")
			if action.name == "Mind Games":
				damage = amt * 4
				player.remove_buff("Dodge")

		if damage > 0:
			if action.damage_type == Action.DamageType.HP:
				AudioController.play_sfx("heal")
				player.take_healing(damage, "HP")
			if action.damage_type == Action.DamageType.AP:
				AudioController.play_sfx("blip_up")
				player.take_healing(damage, "ST")
			elif action.damage_type == Action.DamageType.AC:
				AudioController.play_sfx("grazed")
				player.take_healing(damage, "AC")
			elif action.damage_type == Action.DamageType.MP:
				AudioController.play_sfx("mp_gain")
				player.take_healing(damage, "MP")
		yield(self, "anim_finished")
		call_deferred("finalize_execute")

func get_action_hits() -> void:
	hits = action.hits
	if action.name == "Mana Storm":
		#warning-ignore:integer_division
		hits = min(5, player.mp/ action.cost)
	if action.name == "Lightning Claws":
		hits = ap_spent

func inflict_hit() -> void:
	if enemy.has_buff("Flame Shield"):
		player.gain_debuff(burn_debuff, 1)
	emit_signal("inflict_hit")

func inflict_effect() -> void:
	emit_signal("inflict_effect")

func create_effect(position: Vector2, type: String) -> void:
	if action.fx == null:
		yield(get_tree().create_timer(0.1), "timeout")
		if type == "hit":
			emit_signal("inflict_hit")
		else:
			emit_signal("inflict_effect")
		yield(get_tree().create_timer(0.2), "timeout")
		emit_signal("anim_finished")
	else:
		var effect = action.fx.instance()
		effect.connect("inflict_hit", self, "inflict_hit")
		effect.connect("inflict_effect", self, "inflict_effect")
		enemy.add_child(effect)
		effect.global_position = position
		yield(effect, "finished")
		emit_signal("anim_finished")

func weapons_played(amt: int) -> void:
	if action.name == "Backstab":
		self.added_damage = amt * action.damage

func weapons_in_hand(qty: int) -> void:
	if action.name == "Chakram":
		self.ap_cost = max(action.cost - qty + 1, 0)
#		update_data()

func set_ap_cost(value: int) -> void:
	ap_cost = value
	update_data()

func set_added_damage(value: int) -> void:
	added_damage = value
	update_data()

func set_weapon_multiplier(value: float) -> void:
	weapon_multiplier = value
	update_data()

func set_spell_multiplier(value: float) -> void:
	spell_multiplier = value
	update_data()

func first_striking() -> bool:
	return actions.actions_used == 0 or player.has_buff("Hide")

func _on_Button_up() -> void:
	update_data()
	timer.stop()
	if hovering:
		hovering = false
		emit_signal("hide_card")
		return
	if played: return
	play()

func _on_Button_down():
	modulate.a = 0.66
	timer.start(.25)

func _on_Timer_timeout() -> void:
	timer.stop()
	hovering = true
	emit_signal("show_card", self)
