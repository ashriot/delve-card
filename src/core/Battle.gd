extends Node2D
class_name Battle

signal start_turn
signal battle_finished(won)
signal show_card(btn, amt)
signal hide_card

var enemy: EnemyActor

onready var actions = $Actions as Actions
onready var enemyUI = $Enemy
onready var playerUI = $Player
onready var deck_val = $DeckBtn/ColorRect/Label
onready var graveyard_val = $GraveyardBtn/Label
onready var enemy_label = $Banner/Label

var auto_end: bool
var game_over: = false
var initialized: = false

func initialize(_player: Actor) -> void:
	actions.connect("deck_count", self, "set_deck_count")
	actions.connect("graveyard_count", self, "set_graveyard_count")
	actions.connect("show_card", self, "show_card")
	actions.connect("hide_card", self, "hide_card")
	playerUI.initialize(_player)
	actions.initialize(playerUI, enemyUI)
	initialized = true

func start(_enemy: EnemyActor) -> void:
	game_over = false
	playerUI.reset()
	actions.reset()
	enemy = _enemy
	enemy_label.text = enemy.name
	enemyUI.initialize(enemy)
	yield(get_tree().create_timer(0.2), "timeout")
	emit_signal("start_turn")

func toggle_auto_end(value: bool) -> void:
	auto_end = value
	actions.auto_end = auto_end

func _on_Actions_ended_turn():
	print("on actions ended turn")
	yield(get_tree().create_timer(0.3), "timeout")
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
	if action.target_type == Action.TargetType.OPPONENT:
		var damage = action.damage * (1 + enemyUI.damage_multiplier) \
			+ (enemyUI.added_damage)
		playerUI.take_hit(damage)
		if action.extra_action != null:
			action.extra_action.execute(playerUI)
		if playerUI.buffs.has("Flame Shield"):
			yield(get_tree().create_timer(0.2), "timeout")
			var burn_debuff = load("res://src/actions/debuffs/burn.tres")
			enemyUI.gain_debuff(burn_debuff, 1)
		if playerUI.buffs.has("Static Shield"):
			yield(get_tree().create_timer(0.2), "timeout")
			var static_shield = load("res://src/actions/debuffs/static_shield.tres")
			var crit = randf() < static_shield.crit_chance
			enemyUI.take_hit(static_shield, static_shield.damage * (2 if crit else 1), crit)
		if playerUI.buffs.has("Mist Shield"):
			yield(get_tree().create_timer(0.2), "timeout")
			playerUI.take_healing(3, "HP")

func show_card(btn, amt: int) -> void:
	emit_signal("show_card", btn, amt)

func hide_card() -> void:
	emit_signal("hide_card")

func _on_Enemy_block_input():
	actions.block_input(true)

func _on_Enemy_died():
	actions.block_input(true)
	emit_signal("battle_finished", true)

func set_deck_count(value: int) -> void:
	deck_val.text = str(value)

func set_graveyard_count(value: int) -> void:
	graveyard_val.text = str(value)

func _on_DeckBtn_button_up():
	AudioController.click()
	actions.show_deck_viewer()
