extends Node
class_name Game

signal battle_finished
signal looting_finished

var gear = preload("res://assets/images/ui/gear_small.png")
var close = preload("res://assets/images/ui/close_small.png")

export var player: Resource
export var rooms: = 5
export var mute: = false
export var skipping_intro: = false

onready var title: = $Title
onready var welcome: = $WelcomeScreen
onready var battle: = $Battle
onready var dungeon: = $Dungeon
onready var loot: = $Loot
onready var blacksmith = $Blacksmith
onready var shop = $Shop
onready var end_game: = $EndGame
onready var fade = $Fade/AnimationPlayer
onready var demo = $DemoScreen
onready var deck = $Deck
onready var card = $Card
onready var char_select = $CharSelect
onready var playerUI = $PlayerUI
onready var settings = $Settings/Dimmer
onready var settings_btn = $Settings/Settings

var profile_hash: int setget, get_profile_hash
var core_data: Resource
var loading: = false

var SAVE_DIR = "user://saves/"
var SAVE_NAME_TEMPLATE: String = "save_%d"
var game_data = GameData.new()

var game_seed: String = "GODOT"

# Settings
var auto_end: = true

func _ready() -> void:
	$Title/AnimationPlayer.play("FlashTap")
	rand_seed(game_seed.hash())
	AudioController.mute = mute
	AudioController.play_bgm("title")
	init_dir()
	dungeon.initialize(self)
	playerUI.hide()
	settings.hide()
	battle.hide()
	loot.hide()
	blacksmith.hide()
	shop.hide()
	dungeon.hide()
	end_game.hide()
	demo.hide()
	deck.hide()
	card.hide()
	welcome.initialize(self)
	welcome.connect("save_core_data", self, "save_core_data")
	$DemoScreen/Notes.hide()
	char_select.hide()
	if skipping_intro:
		skip_intro()
	else:
		title.show()

func init_dir() -> void:
	var dir = Directory.new()
	if !dir.dir_exists(SAVE_DIR + "/core"):
		dir.make_dir_recursive(SAVE_DIR + "/core")

	var save_path = SAVE_DIR.plus_file("core")
	var directory: Directory = Directory.new()
	if not directory.dir_exists(save_path):
		directory.make_dir_recursive(save_path)

	# CREATE DATA
	if !core_exists():
		core_data = CoreData.new()
		core_data.game_version =  ProjectSettings.get_setting("application/config/version")
		var path = save_path.plus_file("core.tres")
		var error: int = ResourceSaver.save(path, core_data)
		check_error(path, error)
	else: # LOAD
		print("loading core")
		save_path = SAVE_DIR.plus_file("core")
		var path = save_path.plus_file("core.tres")
		core_data = load(path)

func save_core_data() -> void:
	print("saving the core -> ", core_data.profile_name)
	var save_path = SAVE_DIR.plus_file("core")
	var path = save_path.plus_file("core.tres")
	var error: int = ResourceSaver.save(path, core_data)
	check_error(path, error)

func core_exists() -> bool:
	var file = File.new()
	var save_path = SAVE_DIR.plus_file("core")
	save_path = save_path.plus_file("core.tres")
	return file.file_exists(save_path)

func save_game() -> void:
	print("saving game!")
	var dir = Directory.new()
	if !dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)

	print(core_data.profile_name, "->", self.profile_hash)
	var save_path = SAVE_DIR.plus_file(SAVE_NAME_TEMPLATE % self.profile_hash)

	var directory: Directory = Directory.new()
	if not directory.dir_exists(save_path):
		directory.make_dir_recursive(save_path)

	# SAVE PLAYER
	var path = save_path.plus_file("player.tres")
	var error: int = ResourceSaver.save(path, player)
	check_error(path, error)
	# SAVE DUNGEON
	path = save_path.plus_file("map.tscn")
	var packed_scene = PackedScene.new()
	packed_scene.pack(dungeon.map)
	error = ResourceSaver.save(path, packed_scene)
	check_error(path, error)
	# SAVE GAME DATA
	game_data.game_version = ProjectSettings.get_setting("application/config/version")
	game_data.profile_name = core_data.profile_name
	game_data.current_square = dungeon.current_square
	game_data.upgrade_cost = blacksmith.upgrade_cost
	game_data.destroy_cost = blacksmith.destroy_cost
	path = save_path.plus_file("data.tres")
	error = ResourceSaver.save(path, game_data)
	check_error(path, error)

func load_game() -> void:
	loading = true
	print("loading game!")
	var save_path = SAVE_DIR.plus_file(SAVE_NAME_TEMPLATE % self.profile_hash)
	var path = save_path.plus_file("data.tres")
	game_data = load(path)
	# Player Data
	path = save_path.plus_file("player.tres")
	player = load(path)
	# Map Data
	path = save_path.plus_file("map.tscn")
	var map = load(path).instance()
	dungeon.map.queue_free()
	map.add_squares_to_astar()
	map.connect_squares()
	map.connect("move_to_square", dungeon, "_on_Map_move_to_square")
	dungeon.add_child_below_node(dungeon.colorRect, map)
	dungeon.map = map
	dungeon.current_square = game_data.current_square
	dungeon.avatar.global_position = dungeon.map.get_pos(game_data.current_square) - Vector2(3, 3) + map.position

func check_error(path, error) -> void:
	if error != OK:
		print("There was an error writing the save %s to %s -> %s" % [core_data.profile_name, path, error])

func save_exists() -> bool:
	var file = File.new()
	var save_path = SAVE_DIR.plus_file(SAVE_NAME_TEMPLATE % self.profile_hash)
	save_path = save_path.plus_file("player.tres")
	return file.file_exists(save_path)

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
	shop.initialize(self)
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
	if scene_to_hide != null: scene_to_hide.hide()
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
	if scene_to_hide != null: scene_to_hide.show()
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

func blacksmithing_deck(smith: Blacksmith) -> void:
	deck.smithing(smith)
	deck.show()

func refresh_player() -> void:
	playerUI.refresh()
	save_game()

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
	# Chance to fight a Mimic!!
	var rand = randf()
	if rand < 0.5:
		var enemy = load("res://src/enemies/mimic.tres")
		start_battle(dungeon, enemy)
		yield(self, "battle_finished")
	else:
		fade.play("FadeOut")
		yield(fade, "animation_finished")
		start_loot(gold, 1)
		yield(self, "looting_finished")
	fade.play("FadeIn")
	save_game()

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
	save_game()

func _on_Dungeon_blacksmith():
	blacksmith.show()
	save_game()

func _on_Dungeon_blank():
	save_game()

func _on_WelcomeScreen_load_game():
	loading = true
	player = playerUI.player
	load_game()
	start_game()

func _on_WelcomeScreen_new():
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	welcome.hide()
	dungeon.new_map()
	char_select.show()
	fade.play("FadeIn")

func _on_WelcomeScreen_profile_chose(username):
	core_data.profile_name = username
	if save_exists():
		welcome.continue_button.disabled = false
	else:
		welcome.continue_button.disabled = true

func get_profile_hash() -> int:
	return core_data.profile_name.hash()

func _on_CharBack_pressed():
	AudioController.back()
	char_select.hide()

func _on_Dungeon_shop():
	shop.show()
	save_game()
