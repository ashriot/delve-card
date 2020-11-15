extends Control
class_name ActionButton

var FloatingText = preload("res://assets/animations/FloatingText.tscn")

signal inflict_hit
signal inflict_effect
signal anim_finished
signal action_finished(action_button)
signal button_pressed(button)
signal unblock(value)
signal discarded(action_button)
signal draw_cards(action)

signal show_card(action_button)
signal hide_card

onready var button = $Button
onready var animationPlayer: = $AnimationPlayer
onready var timer: = $Timer

var action: Action
var player: Player
var enemy: Enemy
var played: = true

var hp_cost: int
var ap_cost: int setget set_ap_cost
var mp_cost: int
#var damage: int
var hits: int

var added_damage: = 0 setget set_added_damage
var weapon_multiplier: = 0.0 setget set_weapon_multiplier
var spell_multiplier: = 0.0 setget set_spell_multiplier

var hovering: = false
var initialized: = false

func initialize(_action: Action, _player: Player, _enemy: Enemy) -> void:
	action = _action
	player = _player
	enemy = _enemy
	$Button/AP.hide()
	$Button/MP.hide()
	$Button/Sprite.frame = action.frame_id
	$Button.text = action.name
	if action.cost_type == Action.DamageType.HP:
		hp_cost = action.cost
	elif action.cost_type == Action.DamageType.AP:
		ap_cost = action.cost
	elif action.cost_type == Action.DamageType.MP:
		mp_cost = action.cost
#	damage = action.damage
	hits = action.hits
	update_data()
	initialized = true

func show() -> void:
	modulate.a = 1
	$Button.modulate.a = 0
	AudioController.play_sfx("draw")
	animationPlayer.play("Draw")
	yield(animationPlayer, "animation_finished")
	update_data()
	played = false

func gain() -> void:
	$Button.modulate.a = 1
	$Button.rect_position = Vector2.ZERO

func discard() -> void:
	played = true
	AudioController.play_sfx("draw")
	if action.fade:
		animationPlayer.play("Drop")
	else:
		animationPlayer.play("Discard")
	yield(animationPlayer, "animation_finished")
	emit_signal("discarded", self)

func update_data() -> void:
	if action.action_type == Action.ActionType.INJURY:
		modulate.a = 0.4
	else:
		modulate.a = 1.0
	if action.cost_type == Action.DamageType.AP and action.cost > 0:
		$Button/AP.rect_size = Vector2(5 * ap_cost, 7)
		$Button/AP.show()
		if action.cost > player.ap:
			modulate.a = 0.4
	elif action.cost_type == Action.DamageType.MP and action.cost > 0:
		$Button/MP.bbcode_text = " " + str(mp_cost) + "MP"
		$Button/MP.show()
		if action.cost > player.mp:
			modulate.a = 0.4
	elif action.cost_type == Action.DamageType.HP and action.cost > 0:
		$Button/MP.bbcode_text = " -" + str(hp_cost) + "HP"
		$Button/MP.show()
		if action.cost > player.hp:
			modulate.a = 0.4

	var hit_text = "" if hits < 2 else ("x" + str(hits))
	var type = "HP" if action.healing else "dmg"
	if action.damage_type == Action.DamageType.AC:
		type = "AC"
	elif action.damage_type == Action.DamageType.MP:
		type = "MP"
	elif action.damage_type == Action.DamageType.AP:
		type = "ST"
	var prepend = "+" if action.healing else ""
	var drown = "+"
	if action.name != "Drown":
		drown = ""
	var damage = action.damage
	var multiplier = 1
	if action.action_type == Action.ActionType.WEAPON:
		multiplier += weapon_multiplier + player.weapon_multiplier
	if action.action_type == Action.ActionType.SPELL:
		multiplier += spell_multiplier + player.weapon_multiplier
	if action.target_type == Action.TargetType.OPPONENT:
		if action.impact > 0:
			added_damage = player.added_damage * (action.impact - 1)
		damage = ((damage + added_damage + player.added_damage) * \
			(multiplier - enemy.damage_reduction)) as int
	var text = "[right]" + prepend + str(damage) + drown + hit_text + type
	if action.damage == 0:
		text = ""
	if action.name == "Brilliant Crystal":
		var glow = min(player.mp, 30)
		text = "[right]" + str(glow) + "MP"
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
	player.ap -= ap_cost
	player.mp -= mp_cost
	player.hp -= hp_cost
	execute()

func finalize_execute() -> void:
	update_data()
	emit_signal("action_finished", self)

func display_error() -> void:
	var floating_text = FloatingText.instance()
	floating_text.display_text(get_error())
	floating_text.position = Vector2(54, 0)
	get_parent().add_child(floating_text)

func execute() -> void:
	if action.target_type == Action.TargetType.OPPONENT:
		var hits = get_action_hits()
		for hit in hits:
			if enemy.dead: break
			if action.name == "Mana Storm" and hit > 0:
				player.mp -= action.cost
			create_effect(enemy.global_position, "hit")
			yield(self, "inflict_hit")
			if action.name == "Conflagration":
				var conflag = load("res://src/actions/debuffs/burn.tres")
				if enemy.has_debuff("Burn"):
					print("already burning")
					var stacks = enemy.get_debuff_stacks("Burn")
					enemy.gain_debuff(conflag, (stacks + 5) * 2)
				else:
					enemy.gain_debuff(conflag, 10)
			if action.damage > 0:
				var roll = randf()
				var crit_mod = 0
				if player.has_buff("Aim"):
					crit_mod = 0.5
				var crit = roll < crit_mod + action.crit_chance
				if action.impact > 0:
					added_damage = player.added_damage * (action.impact - 1)
					print(added_damage)
				var damage = (action.damage + added_damage + player.added_damage) * \
					(1 + weapon_multiplier + player.weapon_multiplier)
				if action.name == "Drown":
					damage += clamp(player.mp, 0, 30)
				damage *= (2 if crit else 1)
				if player.has_buff("Lifesteal"):
					var healing = damage
					player.take_healing(healing, "HP")
				enemy.take_hit(action, damage, crit)
			if action.drawX > 0:
				emit_signal("draw_cards", action)
			if action.extra_action != null:
				if action.name == "Offensive Tactics" \
				and enemy.get_intent() == "Attack":
					action.extra_action.execute(player)
				else:
					action.extra_action.execute(player)
			if !enemy.dead:
				emit_signal("unblock", false)
			if hits > 1 and hit == (hits -1):
				yield(self, "anim_finished")
		if player.has_buff("Lifesteal") and action.damage > 0:
			player.reduce_buff("Lifesteal")
		if player.has_buff("Aim") and action.damage > 0:
			player.reduce_buff("Aim")
		finalize_execute()
	else:
		create_effect(player.global_position, "effect")
		yield(self, "inflict_effect")
		if action.drawX > 0:
			emit_signal("draw_cards", action)
		else:
			emit_signal("unblock", false)
		if action.extra_action != null:
			action.extra_action.execute(player)
		if action.damage > 0:
			if action.damage_type == Action.DamageType.HP:
				AudioController.play_sfx("heal")
				player.take_healing(action.damage, "HP")
			if action.damage_type == Action.DamageType.AP:
				AudioController.play_sfx("blip_up")
				player.take_healing(action.damage, "ST")
			elif action.damage_type == Action.DamageType.AC:
				AudioController.play_sfx("grazed")
				player.take_healing(action.damage, "AC")
			elif action.damage_type == Action.DamageType.MP:
				var damage = action.damage
				if action.name == "Brilliant Crystal":
					damage = min(player.mp, 30)
				AudioController.play_sfx("mp_gain")
				player.take_healing(damage, "MP")
		yield(self, "anim_finished")
		finalize_execute()

func get_action_hits() -> int:
	hits = action.hits
	if action.name == "Mana Storm":
		#warning-ignore:integer_division
		hits = min(5, (player.mp + action.cost) / action.cost)
	return hits

func inflict_hit() -> void:
	if enemy.has_buff("Flame Shield"):
		var burn_debuff = load("res://src/actions/debuffs/burn.tres")
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
	if action.name == "Sneak Attack":
		self.added_damage = amt * action.damage

func weapons_in_hand(qty: int) -> void:
	if action.name == "Chakram":
		self.ap_cost = max(action.cost - qty + 1, 0)

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
