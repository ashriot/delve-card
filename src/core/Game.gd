extends Node
class_name Game

signal battle_finished
signal looting_finished

var gear = preload("res://assets/images/ui/gear_small.png")
var close = preload("res://assets/images/ui/close_small.png")

export var player: Resource
export var rooms: = 5
export var mute: = false
export var skip_intro: = false

onready var game_saver: = $GameSaver
onready var title: = $Title
onready var welcome: = $WelcomeScreen
onready var battle: = $Battle
onready var dungeon: = $Dungeon
onready var loot: = $Loot
onready var blacksmith = $Blacksmith
onready var end_game: = $EndGame
onready var fade = $Fade/AnimationPlayer
onready var demo = $DemoScreen
onready var deck = $Deck
onready var card = $Card
onready var char_select = $CharSelect
onready var playerUI = $PlayerUI
onready var settings = $Settings/Dimmer
onready var settings_btn = $Settings/Settings

export var profile_id: int = 0

var loading: = false
var game_seed: String = "GODOT"

# Settings
var auto_end: = true

func _ready() -> void:
	$Title/AnimationPlayer.play("FlashTap")
	rand_seed(game_seed.hash())
	AudioController.mute = mute
	AudioController.play_bgm("title")
	dungeon.initialize(self)
	playerUI.hide()
	settings.hide()
	battle.hide()
	loot.hide()
	blacksmith.hide()
	dungeon.hide()
	end_game.hide()
	demo.hide()
	deck.hide()
	card.hide()
	welcome.initialize(game_saver)
	$DemoScreen/Notes.hide()
	char_select.hide()
	if skip_intro:
		skip_intro()
	else:
		title.show()

func save_game() -> void:
	welcome.game_saver.save(profile_id)

func _on_StartGame_button_up() -> void:
	AudioController.click()
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	title.hide()
	demo.show()
	fade.play("FadeIn")
	yield(fade, "animation_finished")

func start_game() -> void:
	title.hide()
	welcome.hide()
	char_select.hide()
	demo.hide()
	refresh_dungeon()
	blacksmith.initialize(self)
	deck.initialize(self)
	deck.connect("show_card", self, "show_card")
	deck.connect("hide_card", self, "hide_card")
	battle.initialize(player)
	battle.toggle_auto_end(true)
	battle.connect("show_card", self, "show_card")
	battle.connect("hide_card", self, "hide_card")
	loot.initialize(self)
	dungeon.show()
	playerUI.initialize(self)
	playerUI.show()
	fade.play("FadeIn")
	AudioController.play_bgm("dungeon")
	yield(fade, "animation_finished")
	save_game()

func start_battle(scene_to_hide: Node2D, enemy: EnemyActor) -> void:
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	scene_to_hide.hide()
	playerUI.hide()
	battle.show()
	battle.start(enemy)
	fade.play("FadeIn")
	yield(battle, "battle_finished")
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	battle.hide()
	playerUI.refresh()
	playerUI.show()
	if battle.game_over:
		game_over()
		return
#	AudioController.play_bgm("victory")
	start_loot(enemy.gold, 3)
	yield(self, "looting_finished")
	scene_to_hide.show()
#	AudioController.play_bgm("dungeon")
	fade.play("FadeIn")
	emit_signal("battle_finished")

func start_loot(gold: int, qty: int) -> void:
	loot.setup(dungeon.progress, gold, qty)
	playerUI.show()
	loot.show()
	fade.play("FadeIn")
	yield(loot, "looting_finished")
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	playerUI.refresh()
	loot.hide()
	emit_signal("looting_finished")
	save_game()

func game_over() -> void:
	AudioController.play_bgm("title")
	player.hp = player.max_hp
	$EndGame/Label.text = "Game Over"
	end_game.show()
	fade.play("FadeIn")

func refresh_dungeon() -> void:
	pass

func open_deck() -> void:
	deck.refresh(0)
	deck.show()

func blacksmithing_deck(blacksmith: Blacksmith) -> void:
	deck.smithing(blacksmith)
	deck.show()

func refresh_player() -> void:
	playerUI.refresh()

func _on_Restart_button_up():
	AudioController.click()
	player.hp = player.max_hp
	dungeon.reset()
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	end_game.hide()
	dungeon.show()
	AudioController.play_bgm("dungeon")
	fade.play("FadeIn")

func _on_DemoStart_button_up():
	AudioController.click()
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	demo.hide()
	welcome.show()
	fade.play("FadeIn")

func _on_CharSelect_chose_class(name: String) -> void:
	var n = name.to_lower()
	var player_res = load("res://src/actions/" + n + "/" + n + ".tres")
	player = player_res
	skip_intro()

func skip_intro() -> void:
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	char_select.hide()
	start_game()

func _on_Patch_button_up():
	AudioController.click()
	$DemoScreen/Notes.show()

func _on_PatchBack_button_up():
	AudioController.back()
	$DemoScreen/Notes.hide()

func _on_Fire_button_up():
	AudioController.click()
	var n = "fire_sorc"
	player = load("res://src/actions/sorcerer/" + n + ".tres")
	skip_intro()

func _on_Arcane_button_up():
	AudioController.click()
	var n = "arcane_sorc"
	player = load("res://src/actions/sorcerer/" + n + ".tres")
	skip_intro()

func show_card(btn, amt: int) -> void:
	card.initialize(btn, amt)

func hide_card() -> void:
	card.hide()

func _on_AutoEnd_toggled(button_pressed):
	AudioController.click()
	auto_end = button_pressed
	battle.toggle_auto_end(auto_end)

func _on_Settings_button_up():
	settings_btn.modulate.a = 1
	if !settings.visible:
		AudioController.click()
		settings.show()
		settings_btn.texture_normal = close
	else:
		settings_btn.texture_normal = gear
		AudioController.back()
		settings.hide()

func _on_Dungeon_start_battle(enemy: EnemyActor) -> void:
	start_battle(dungeon, enemy)
	yield(self, "battle_finished")

func _on_Dungeon_start_loot(gold):
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	start_loot(gold, 1)
	yield(self, "looting_finished")
	fade.play("FadeIn")

func _on_Settings_button_down():
	settings_btn.modulate.a = 0.66

func _on_Dungeon_heal():
	playerUI.heal(5, "HP")

func _on_Dungeon_advance():
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	if dungeon.progress == 5:
		$EndGame/Label.text = "Thank you for playing!"
		end_game.show()
	else:
		dungeon.reset_avatar()
	yield(get_tree().create_timer(0.25), "timeout")
	fade.play("FadeIn")

func _on_Dungeon_blacksmith():
	blacksmith.show()

func _on_WelcomeScreen_done():
	loading = true
	player = playerUI.player
	start_game()

func _on_WelcomeScreen_new():
	welcome.hide()
	char_select.show()
