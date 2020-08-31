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

func initialize(_player: Actor) -> void:
	actions.connect("deck_count", playerUI, "set_deck_count")
	actions.connect("graveyard_count", playerUI, "set_graveyard_count")
	playerUI.initialize(_player)
	actions.initialize(playerUI, enemyUI)
	initialized = true

func start(_enemy: Actor) -> void:
	game_over = false
	actions.reset_deck()
	playerUI.reset()
	enemy = _enemy
	enemyUI.initialize(enemy)
	yield(get_tree().create_timer(0.2), "timeout")
	emit_signal("start_turn")

func _on_Actions_ended_turn():
	yield(get_tree().create_timer(0.2), "timeout")
	enemyUI.act()
	yield(enemyUI, "ended_turn")
	if playerUI.dead:
		game_over = true
		emit_signal("battle_finished", false)
	else:
		emit_signal("start_turn")

func _on_Enemy_used_action(action: Action):
	playerUI.take_hit(action.damage)

func _on_Enemy_block_input():
	actions.block_input(true)

func _on_Enemy_died():
	actions.block_input(true)
	emit_signal("battle_finished", true)
