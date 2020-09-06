extends Node2D
class_name Battle

signal start_turn
signal battle_finished(won)

var enemy: Actor

onready var actions = $Actions as Actions
onready var enemyUI = $Enemy
onready var playerUI = $Player

var game_over: = false
var initialized: = false

func initialize(_player: Actor, auto: bool) -> void:
	actions.connect("deck_count", playerUI, "set_deck_count")
	actions.connect("graveyard_count", playerUI, "set_graveyard_count")
	playerUI.initialize(_player)
	actions.initialize(playerUI, enemyUI, auto)
	initialized = true

func start(_enemy: Actor, auto: bool) -> void:
	game_over = false
	actions.reset_deck()
	playerUI.reset()
	actions.reset(auto)
	enemy = _enemy
	enemyUI.initialize(enemy)
	yield(get_tree().create_timer(0.2), "timeout")
	emit_signal("start_turn")

func _on_Actions_ended_turn():
	yield(get_tree().create_timer(0.6), "timeout")
	enemyUI.act()
	yield(enemyUI, "ended_turn")
	if playerUI.dead:
		game_over = true
		emit_signal("battle_finished", false)
	elif enemyUI.dead:
		enemyUI.die()
	else:
		emit_signal("start_turn")

func _on_Enemy_used_action(action: Action):
	var damage = action.damage * (1 + enemyUI.damage_multiplier)
	playerUI.take_hit(damage)
	if playerUI.buffs.has("Flame Shield"):
		yield(get_tree().create_timer(0.2), "timeout")
		var burn_debuff = load("res://src/actions/debuffs/burn.tres")
		enemyUI.gain_debuff(burn_debuff, 1)
	if playerUI.buffs.has("Voltaic Barrier"):
		yield(get_tree().create_timer(0.2), "timeout")
		var voltaic = load("res://src/actions/debuffs/voltaic.tres")
		var crit = randf() < voltaic.crit_chance
		enemyUI.take_hit(voltaic, voltaic.damage * (2 if crit else 1), crit)
	if playerUI.buffs.has("Misty Veil"):
		yield(get_tree().create_timer(0.2), "timeout")
		playerUI.take_healing(3, "HP")

func _on_Enemy_block_input():
	actions.block_input(true)

func _on_Enemy_died():
	actions.block_input(true)
	emit_signal("battle_finished", true)
