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

onready var title: = $Title
onready var battle: = $Battle
onready var dungeon: = $Dungeon
onready var loot: = $Loot
onready var blacksmith = $Blacksmith
onready var end_game: = $EndGame
onready var fade = $Fade/AnimationPlayer
onready var demo = $DemoScreen
onready var card = $Card
onready var char_select = $CharSelect
onready var playerUI = $PlayerUI
onready var settings = $Settings/Dimmer
onready var settings_btn = $Settings/Settings

# Settings
var auto_end: = true

func _ready() -> void:
	$Title/AnimationPlayer.play("FlashTap")
	randomize()
	AudioController.mute = mute
	AudioController.play_bgm("title")
	dungeon.initialize()
	playerUI.hide()
	settings.hide()
	battle.hide()
	loot.hide()
	blacksmith.hide()
	dungeon.hide()
	end_game.hide()
	demo.hide()
	card.hide()
	$DemoScreen/Notes.hide()
	char_select.hide()
	if skip_intro:
		_on_DemoStart_button_up()
	else:
		title.show()

func _on_StartGame_button_up() -> void:
	AudioController.click()
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	title.hide()
	demo.show()
	fade.play("FadeIn")
	yield(fade, "animation_finished")

func start_game() -> void:
	battle.initialize(player)
	battle.toggle_auto_end(true)
	battle.connect("show_card", self, "show_card")
	battle.connect("hide_card", self, "hide_card")
	loot.initialize(player)
	dungeon.show()
	playerUI.show()
	fade.play("FadeIn")
	AudioController.play_bgm("dungeon")
	yield(fade, "animation_finished")

func start_battle(scene_to_hide: Node2D, enemy: Actor) -> void:
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
	playerUI.show()
	playerUI.refresh()
	if battle.game_over:
		game_over()
		return
	AudioController.play_bgm("victory")
	start_loot()
	yield(self, "looting_finished")
	scene_to_hide.show()
	AudioController.play_bgm("dungeon")
	fade.play("FadeIn")
	emit_signal("battle_finished")

func start_loot() -> void:
	loot.setup(dungeon.progress)
	playerUI.show()
	loot.show()
	fade.play("FadeIn")
	yield(loot, "looting_finished")
	playerUI.refresh()
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	loot.hide()
	emit_signal("looting_finished")

func game_over() -> void:
	AudioController.play_bgm("title")
	player.hp = player.max_hp
	$EndGame/Label.text = "Game Over"
	end_game.show()
	fade.play("FadeIn")

func refresh_dungeon() -> void:
	pass

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
	char_select.show()
	fade.play("FadeIn")

func _on_CharSelect_chose_class(name: String) -> void:
	var n = name.to_lower()
	var player_res = load("res://src/actions/" + n + "/" + n + ".tres")
	player = player_res
	refresh_dungeon()
	playerUI.initialize(player)
	playerUI.connect("show_card", self, "show_card")
	playerUI.connect("hide_card", self, "hide_card")
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
	var player_res = load("res://src/actions/sorcerer/" + n + ".tres")
	player = player_res
	refresh_dungeon()
	playerUI.initialize(player)
	playerUI.connect("show_card", self, "show_card")
	playerUI.connect("hide_card", self, "hide_card")
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	char_select.hide()
	start_game()

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

func _on_Dungeon_start_battle(enemy: Actor) -> void:
	start_battle(dungeon, enemy)
	yield(self, "battle_finished")

func _on_Dungeon_start_loot():
	start_loot()
	yield(self, "looting_finished")
	fade.play("FadeIn")

func _on_Settings_button_down():
	settings_btn.modulate.a = 0.66

func _on_Dungeon_heal():
	AudioController.play_sfx("heal")
	playerUI.heal(5)

func _on_Dungeon_advance():
	fade.play("FadeOut")
	AudioController.play_sfx("footsteps")
	yield(fade, "animation_finished")
	if dungeon.progress == 5:
		$EndGame/Label.text = "Thank you for playing!"
		end_game.show()
	else:
		dungeon.reset_avatar()
	yield(get_tree().create_timer(0.5), "timeout")
	fade.play("FadeIn")

func _on_Dungeon_blacksmith():
	fade.play("FadeOut")
	AudioController.play_sfx("footsteps")
	yield(fade, "animation_finished")
	blacksmith.show()
	fade.play("FadeIn")
