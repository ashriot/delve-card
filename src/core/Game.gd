extends Node
class_name Game

signal battle_finished

export var player: Resource
export var rooms: = 5
export var mute: = false
export var skip_intro: = false

onready var title: = $Title
onready var battle: = $Battle
onready var dungeon: = $Dungeon
onready var loot: = $Loot
onready var end_game: = $EndGame
onready var fade = $Fade/AnimationPlayer
onready var demo = $DemoScreen
onready var char_select = $CharSelect
onready var playerUI = $PlayerUI
onready var settings = $Settings/Dimmer

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
	dungeon.hide()
	end_game.hide()
	demo.hide()
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

func _on_Dungeon_start_battle(enemy: Actor) -> void:
	start_battle(dungeon, enemy)
	yield(self, "battle_finished")
	if dungeon.progress == 9:
		$EndGame/Label.text = "Thank you for playing!"
		end_game.show()
	else:
		dungeon.advance()

func start_game() -> void:
	battle.initialize(player, auto_end)
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
	battle.start(enemy, auto_end)
	fade.play("FadeIn")
	yield(fade, "animation_finished")
	yield(battle, "battle_finished")
	fade.play("FadeOut")
	if battle.game_over:
		game_over()
		return
	AudioController.play_bgm("victory")
	yield(fade, "animation_finished")
	battle.hide()
	loot.setup(dungeon.progress)
	playerUI.show()
	loot.show()
	fade.play("FadeIn")
	yield(loot, "looting_finished")
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	loot.hide()
	scene_to_hide.show()
	AudioController.play_bgm("dungeon")	
	fade.play("FadeIn")
	emit_signal("battle_finished")

func game_over() -> void:
	battle.hide()
	AudioController.play_bgm("title")
	yield(fade, "animation_finished")
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
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	char_select.hide()
	start_game()

func _on_AutoEnd_toggled(button_pressed):
	auto_end = button_pressed
	print(button_pressed)

func _on_Settings_button_up():
	if !settings.visible:
		AudioController.click()
		settings.show()
	else:
		AudioController.back()
		settings.hide()
