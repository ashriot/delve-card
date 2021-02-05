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
	enemyUI.connect("ended_turn", self, "_on_Enemy_ended_turn")
	playerUI.initialize(_player)
	actions.initialize(playerUI, enemyUI)
	initialized = true

func start(_enemy: EnemyActor) -> void:
	game_over = false
	playerUI.reset()
	actions.reset()
	enemy = _enemy
	enemy_label.text = enemy.title
	enemyUI.initialize(enemy, playerUI)
	check_battle_start_effects()
	yield(get_tree().create_timer(0.2), "timeout")
	emit_signal("start_turn")

func toggle_auto_end(value: bool) -> void:
	auto_end = value
	actions.auto_end = auto_end

func _on_Actions_ended_turn():
	print("on actions ended turn")
	end_of_turn()
	yield(get_tree().create_timer(0.3), "timeout")
	if playerUI.has_buff("Time Warp"): emit_signal("start_turn")
	else: enemyUI.act()

func end_of_turn() -> void:
	if playerUI.has_buff("Mend"):
		AudioController.play_sfx("heal")
		playerUI.take_healing(playerUI.buffs["Mend"].stacks, "HP")
		playerUI.reduce_buff("Mend")
		yield(get_tree().create_timer(0.8), "timeout")

func _on_Enemy_ended_turn():
	if playerUI.dead:
		game_over = true
		emit_signal("battle_finished", false)
	elif enemyUI.dead:
		enemyUI.die()
	else:
		print("enemyUI 'ended_turn' signal received --> start_turn")
		emit_signal("start_turn")

func _on_Enemy_used_action(action: Action):
	if action.target_type == Action.TargetType.OPPONENT:
		for x in action.hits:
			var damage = action.damage * (1 + enemyUI.damage_multiplier) \
				+ (enemyUI.added_damage)
			var missed = playerUI.take_hit(action, damage)
			if action.extra_action != null and !missed:
				action.extra_action.execute(playerUI)
			if playerUI.buffs.has("Flame Shield"):
				var burn_debuff = load("res://src/actions/debuffs/burn.tres")
				enemyUI.gain_debuff(burn_debuff, 1)
			if playerUI.buffs.has("Static Shield"):
				var static_shield = load("res://src/actions/debuffs/static_shield.tres")
				var crit = randf() < static_shield.crit_chance
				enemyUI.take_hit(static_shield, static_shield.damage * (2 if crit else 1), crit)
			if playerUI.buffs.has("Mist Shield"):
				playerUI.take_healing(2, "HP")
			if x < action.hits:
				yield(get_tree().create_timer(0.4), "timeout")

func check_battle_start_effects() -> void:
	for trinket in playerUI.actor.trinkets:
		trinket = trinket as Trinket
		if trinket.name == "Crown of Power":
			playerUI.gain_buff(preload("res://src/actions/buffs/power.tres"), 4)

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

func _on_DeckBtn_pressed():
	AudioController.click()
	actions.show_deck_viewer()

func _on_Instakill_pressed():
	enemyUI.die()

func _on_Player_update_enemy():
	enemyUI.update_data()
