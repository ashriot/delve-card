extends Control
class_name ActionButton

var FloatingText = preload("res://assets/animations/FloatingText.tscn")

signal inflict_hit
signal inflict_effect
signal anim_finished
signal action_finished
signal button_pressed(block)
signal played(action_button)
signal discarded(action_button)

signal show_card(action_button)
signal hide_card

onready var button = $Button
onready var animationPlayer: = $AnimationPlayer
onready var timer: = $Timer

var action: Action
var player: Player
var enemy: Enemy
var played: = false

var ap_cost: int
var mp_cost: int
var damage: int
var hits: int

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
	ap_cost = action.ap_cost
	mp_cost = action.mp_cost
	damage = action.damage
	hits = action.hits
	update_data()
	initialized = true

func show() -> void:
	$Button.modulate.a = 0
	AudioController.play_sfx("draw")
	animationPlayer.play("Draw")
	yield(animationPlayer, "animation_finished")
	played = false

func discard() -> void:
	AudioController.play_sfx("draw")
	animationPlayer.play("Discard")
	yield(animationPlayer, "animation_finished")
	emit_signal("discarded", self)

func update_data() -> void:
	if action.ap_cost > 0:
		$Button/AP.rect_size = Vector2(5 * action.ap_cost, 7)
		$Button/AP.show()
	elif action.mp_cost > 0:
		$Button/MP.bbcode_text = " " + str(action.mp_cost) + "MP"
		$Button/MP.show()
	
	var hit_text = "" if hits < 2 else ("x" + str(hits))
	var type = "HP" if action.healing else "dmg"
	if action.damage_type == Action.DamageType.AC:
		type = "AC"
	elif action.damage_type == Action.DamageType.MP:
		type = "MP"
	elif action.damage_type == Action.DamageType.AP:
		type = "AP"
	var prepend = "+" if action.healing else ""
	var text = "[right]" + prepend + str(damage) + hit_text + type
	if action.damage == 0:
		text = ""
	$Button/Damage.bbcode_text = text

func playable() -> bool:
	if ap_cost > player.ap:
		return false
	if mp_cost > player.mp:
		return false
	return true

func get_error() -> String:
	if ap_cost > player.ap:
		return "Not Enough AP!"
	if mp_cost > player.mp:
		return "Not Enough MP!"
	return "Something's missing!"

func play() -> void:
	if !playable():
		display_error()
		return
	played = true
	emit_signal("button_pressed", true)
	if action.drop or action.consume:
		animationPlayer.play("Drop")
	else:
		animationPlayer.play("Use")
	player.ap -= ap_cost
	player.mp -= mp_cost
	execute()
	yield(animationPlayer, "animation_finished")
	emit_signal("played", self)

func display_error() -> void:
	var floating_text = FloatingText.instance()
	floating_text.display_text(get_error())
	floating_text.position = Vector2(54, 0)
	add_child(floating_text)

func execute() -> void:
#	var hit = Hit.new() as Hit
#	hit.initialize(Player.player, target.enemy, action)
	if action.target_type == Action.TargetType.OPPONENT:
		for hit in action.hits:
			create_effect(enemy.global_position)
			yield(self, "inflict_hit")
			emit_signal("action_finished", action)
			var crit = randf() < action.crit_chance
			var damage = action.damage * (2 if crit else 1)
			if action.name == "Drown":
				damage += clamp(player.mp, 0, 20)
			enemy.take_hit(action, damage, crit)
			yield(self, "anim_finished")
	else:
		if action.fx != null:
			create_effect(player.global_position)
			yield(self, "inflict_effect")
			if action.extra_action != null:
				action.extra_action.execute(player)
		if action.damage > 0:
			if action.damage_type == Action.DamageType.HP:
				AudioController.play_sfx("heal")
				player.take_healing(action.damage, "HP")
			if action.damage_type == Action.DamageType.AP:
				AudioController.play_sfx("blip_up")
				player.take_healing(action.damage, "AP")
			elif action.damage_type == Action.DamageType.AC:
				AudioController.play_sfx("grazed")
				player.take_healing(action.damage, "AC")
			elif action.damage_type == Action.DamageType.MP:
				AudioController.play_sfx("mp_gain")
				player.take_healing(action.damage, "MP")
		emit_signal("action_finished", action)
		yield(self, "anim_finished")
	if action.drop or action.consume:
		queue_free()

func inflict_hit() -> void:
	emit_signal("inflict_hit")
	
func inflict_effect() -> void:
	emit_signal("inflict_effect")

func create_effect(position: Vector2) -> void:
	if action.fx == null:
		yield(get_tree().create_timer(0.1), "timeout")
		emit_signal("inflict_hit")
		yield(get_tree().create_timer(0.1), "timeout")
		emit_signal("anim_finished")
	else:
		var effect = action.fx.instance()
		effect.connect("inflict_hit", self, "inflict_hit")
		effect.connect("inflict_effect", self, "inflict_effect")
		enemy.add_child(effect)
		effect.global_position = position
		yield(effect, "finished")
		emit_signal("anim_finished")

func _on_Button_up() -> void:
	timer.stop()
	if played: return
	if hovering:
		hovering = false
		emit_signal("hide_card")
		return
	play()

func _on_Button_down():
	timer.start(.25)

func _on_Timer_timeout() -> void:
	timer.stop()
	hovering = true
	emit_signal("show_card", self)
