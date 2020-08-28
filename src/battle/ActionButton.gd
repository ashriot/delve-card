extends Node2D
class_name ActionButton

var FloatingText = preload("res://assets/animations/FloatingText.tscn")

signal inflict_hit
signal anim_finished
signal action_finished
signal button_pressed(block)
signal played(action_button)
signal discarded(action_button)

onready var animationPlayer: = $Button/AnimationPlayer

var deck: Node2D
var graveyard: Node2D

var action: Action
var player: Player
var enemy: Enemy

var ap_cost: int
var mp_cost: int
var damage: int
var hits: int

var initialized: = false

func initialize(_action: Action, _player: Player, \
	_enemy: Enemy, _deck: Node2D, _graveyard: Node2D) -> void:
	action = _action
	player = _player
	enemy = _enemy
	deck = _deck
	graveyard = _graveyard
	$Button/AP.hide()
	$Button/MP.hide()
	$Button/Sprite.frame = action.frame_id
	$Button.text = action.name
	ap_cost = action.ap_cost
	mp_cost = action.mp_cost
	damage = action.damage
	hits = action.hits
	update_data()

func show() -> void:
	$Button.modulate.a = 0
	AudioController.play_sfx("draw")
	animationPlayer.play("Draw")
	yield(animationPlayer, "animation_finished")

func discard() -> void:
	AudioController.play_sfx("draw")
	animationPlayer.play("Discard")
	yield(animationPlayer, "animation_finished")
	emit_signal("discarded", self)

func update_data() -> void:
	if action.ap_cost > 0:
		$Button/AP.show()
		$Button/AP.rect_size = Vector2(5 * action.ap_cost, 7)
	elif action.mp_cost > 0:
		$Button/MP.show()
		$Button/MP.text = str(action.mp_cost) + "MP"
	
	var hit_text = "" if hits < 2 else ("x" + str(hits))
	$Button/Damage.bbcode_text = "[right]" + str(damage) + hit_text

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
	emit_signal("button_pressed", true)
#	print("Playing " + action.name + "!")
	animationPlayer.play("Use")
	execute()
	yield(animationPlayer, "animation_finished")
	emit_signal("played", self)

func display_error() -> void:
	var floating_text = FloatingText.instance()
	floating_text.display_text(get_error())
	floating_text.position = Vector2(54, 0)
	add_child(floating_text)

func execute() -> void:
	player.ap -= ap_cost
	player.mp -= mp_cost
#	var hit = Hit.new() as Hit
#	hit.initialize(Player.player, target.enemy, action)
	if action.target_type == Action.TargetType.OPPONENT:
		for hit in action.hits:
			print("hit: ", hit)
			create_effect(enemy.global_position)
			yield(self, "inflict_hit")
			enemy.take_hit(action.damage)
			yield(self, "anim_finished")
	else:
		if action.damage_type == Action.DamageType.AP:
			AudioController.play_sfx("wind_up")
			player.ap += damage
		elif action.damage_type == Action.DamageType.AC:
			AudioController.play_sfx("hit")
			player.ac += damage
	emit_signal("action_finished", action)

func inflict_hit() -> void:
	emit_signal("inflict_hit")

func create_effect(position: Vector2) -> void:
	if action.fx == null:
		yield(get_tree().create_timer(0.1), "timeout")
		emit_signal("inflict_hit")
		yield(get_tree().create_timer(0.1), "timeout")
		emit_signal("anim_finished")
	else:
		var effect = action.fx.instance()
		effect.connect("inflict_hit", self, "inflict_hit")
		enemy.add_child(effect)
		effect.global_position = position
		yield(effect, "finished")
		emit_signal("anim_finished")

func _on_button_up():
	play()

func _on_Button_button_down():
	pass # Replace with function body.
