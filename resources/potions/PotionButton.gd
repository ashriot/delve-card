extends Control
class_name PotionButton

signal inflict_hit
signal anim_finished
signal unblock(value)
signal draw_cards(action)

signal show_card(button)
signal hide_card
signal used_potion(button)

onready var button:= $Button
onready var sprite:= $Button/Sprite
onready var timer:= $Timer

var action: Resource
var player: Player
var hovering:= false
var initialized:= false
var enemy: Enemy

func initialize(actions, _action: Action, _enemy: Enemy) -> void:
	connect("unblock", actions, "block_input")
	connect("draw_cards", actions, "draw_cards")
	connect("used_potion", actions, "used_potion")
	connect("show_card", actions, "show_card")
	connect("hide_card", actions, "hide_card")
	action = _action
	player = actions.player
	enemy = _enemy
	sprite.frame = action.frame_id
	initialized = true

func execute() -> void:
	hide()
	if action.target_type == Action.TargetType.MYSELF:
#		create_effect(player.global_position, "effect")
#		yield(self, "inflict_effect")
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
				AudioController.play_sfx("mp_gain")
				player.take_healing(damage, "MP")
	else:
		for hit in action.hits:
			create_effect(enemy.global_position, "hit")
			yield(self, "inflict_hit")
			if enemy.dead: break
			var damage = action.damage
			if damage > 0:
				var bonus = 0
				damage *= (1 - enemy.damage_reduction)
				enemy.take_hit(action, damage, false)
			if action.extra_action != null:
				action.extra_action.execute(player)
			if !enemy.dead:
				emit_signal("unblock", false)
			if action.hits > 1:
				yield(get_tree().create_timer(0.1), "timeout")
	player.actor.potions.erase(action)
	get_tree().call_group("action_button", "update_data")

func _on_Button_up():
	sprite.modulate.a = 1
	timer.stop()
	if hovering:
		hovering = false
		emit_signal("hide_card")
	else:
		emit_signal("used_potion", self)

func _on_Button_button_down():
	sprite.modulate.a = 0.66
	timer.start(.25)

func _on_Timer_timeout() -> void:
	timer.stop()
	hovering = true
	emit_signal("show_card", self)


func inflict_hit() -> void:
	emit_signal("inflict_hit")

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
		enemy.add_child(effect)
		effect.global_position = position
		yield(effect, "finished")
		emit_signal("anim_finished")
	queue_free()
