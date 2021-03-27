extends Node
class_name Game

signal battle_finished
signal looting_finished

var gear_icon = preload("res://assets/images/ui/gear_small.png")
var close = preload("res://assets/images/ui/close_small.png")

export var player: Resource
export var rooms: int
export var mute: = false
export var skipping_intro: = false
export(Array, Resource) var jobs

onready var title: = $Title
onready var welcome: = $WelcomeScreen
onready var trait_picker: = $TraitPicker
onready var battle: = $Battle
onready var dungeon: = $Dungeon
onready var loot: = $Loot
onready var blacksmith = $Blacksmith
onready var shop = $Shop
onready var end_game: = $Endgame
onready var event = $EventScreen
onready var fade = $Fade/AnimationPlayer
onready var demo = $DemoScreen
onready var deck = $Deck
onready var card = $Card
onready var char_select = $CharSelect
onready var playerUI = $PlayerUI
onready var settings = $Settings/Dimmer
onready var settings_btn = $Settings/Settings
onready var gem_shop = $GemShop
onready var open_gem_shop = $OpenGemShop

var gems: = 0 setget set_gems

var merchants: Dictionary
var traits: Array

var profile_hash: int setget, get_profile_hash
var core_data: Resource
var loading: = false

var SAVE_DIR = "user://saves/"
var SAVE_NAME_TEMPLATE: String = "save_%d"
var game_data = GameData.new()

var game_seed: String = "GODOT" # randomize eventually

# Settings
var auto_end: = true

func _ready() -> void:
	$Title/AnimationPlayer.play("FlashTap")
	rand_seed(game_seed.hash())
	randomize()
	AudioController.mute = mute
	AudioController.play_bgm("title")
	init_data()		# Initial data creation or load
	open_gem_shop.hide()
	playerUI.hide()
	settings.hide()
	battle.hide()
	loot.hide()
	blacksmith.hide()
	shop.hide()
	dungeon.hide()
	event.hide()
	end_game.hide()
	demo.hide()
	deck.hide()
	card.hide()
	welcome.initialize(self)
	welcome.connect("save_core_data", self, "save_core_data")
	$DemoScreen/Notes.hide()
	char_select.hide()
	title.show()

func init_data() -> void:
	var dir = Directory.new()
	if !dir.dir_exists(SAVE_DIR + "/core"):
		dir.make_dir_recursive(SAVE_DIR + "/core")
	var save_path = SAVE_DIR.plus_file("core")
	var directory: Directory = Directory.new()
	if not directory.dir_exists(save_path):
		directory.make_dir_recursive(save_path)

	# CREATE DATA
	if core_exists(): # LOAD GAME
		print("loading core")
		save_path = SAVE_DIR.plus_file("core")
		var path = save_path.plus_file("core.tres")
		core_data = load(path)
		if core_data.game_version == ProjectSettings.get_setting("application/config/version"):
			self.gems = core_data.gems
			load_job_data()
			return
		print("REPLACE OUTDATED FILE")
	# NEW GAME
	core_data = CoreData.new()
	core_data.gems = 1000
	self.gems = 1000
	core_data.game_version = ProjectSettings.get_setting("application/config/version")
	var path = save_path.plus_file("core.tres")
	var error: int = ResourceSaver.save(path, core_data)
	initialize_job_data()
	check_error(path, error)

func initialize_job_data() -> void:
	for job in jobs:
		job = job as Job
		var data = {}
		data["unlocked"] = job.unlocked
		data["level"] = job.level
		data["xp"] = job.xp
		data["perks"] = {}
		data["gears"] = {}
		data["builds"] = {}
		for perk in job.perks:
			perk = perk as Perk
			data["perks"][perk.name] = 0
		for gear in job.gears:
			gear = gear as Gear
			data["gears"][gear.name] = false
		for build in job.builds:
			build = build as Gear
			data["builds"][build.name] = false
		core_data.job_data[job.name] = data

func load_job_data() -> void:
	for job in jobs:
		job = job as Job
		var data = core_data.job_data[job.name]
		job.unlocked = data.unlocked
		job.level = data.level
		job.xp = data.xp
		for perk in job.perks:
			perk = perk as Perk
			if !data["perks"].keys().has(perk.name):
				data["perks"][perk.name] = 0
			else:
				perk.cur_ranks = data["perks"][perk.name]
		for gear in job.gears:
			gear = gear as Gear
			if !data.has("gears"): data["gears"] = {} # TEMP
			if !data["gears"].keys().has(gear.name):
				data["gears"][gear.name] = false
			else:
				gear.unlocked = data["gears"][gear.name]
		for build in job.builds:
			build = build as Gear
			if !data.has("builds"): data["builds"] = {} # TEMP
			if !data["builds"].keys().has(build.name):
				data["builds"][build.name] = false
			else:
				build.unlocked = data["builds"][build.name]

func save_job_data(job: Job) -> void:
	print("saving job data for ", job.name)
	var data = core_data.job_data[job.name]
	data.level = job.level
	data.xp = job.xp
	data["unlocked"] = job.unlocked
	for perk in job.perks:
		perk = perk as Perk
		data["perks"][perk.name] = perk.cur_ranks
	for gear in job.gears:
		gear = gear as Gear
		data["gears"][gear.name] = gear.unlocked
	for build in job.builds:
		build = build as Gear
		data["builds"][build.name] = build.unlocked
	save_core_data()

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
	# SAVE CORE DATA VERSION NUMBER
	print("saving game!")
	var dir = Directory.new()
	if !dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)

	var save_path = SAVE_DIR.plus_file(SAVE_NAME_TEMPLATE % self.profile_hash)

	var directory: Directory = Directory.new()
	if not directory.dir_exists(save_path):
		directory.make_dir_recursive(save_path)

	# SAVE PLAYER
	var path = save_path.plus_file("player.tres")
	var error: int = ResourceSaver.save(path, player)
	check_error(path, error)

	# SAVE DUNGEON
	game_data.dungeon = {
		"dungeon_name": dungeon.dungeon_name,
		"progress": dungeon.progress,
		"max_prog": dungeon.max_prog
		}
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
	game_data.merchants = merchants
	game_data.active_traits = player.active_traits
	path = save_path.plus_file("data.tres")
	error = ResourceSaver.save(path, game_data)
	check_error(path, error)

func load_game() -> void:
	var save_path = SAVE_DIR.plus_file(SAVE_NAME_TEMPLATE % self.profile_hash)
	var path = save_path.plus_file("data.tres")
	game_data = load(path)
	loading = true

	# Player Data
	path = save_path.plus_file("player.tres")
	player = load(path)

	# Merchants Data
	merchants = game_data.merchants

	# Map Data
	var dungeon_data = game_data.dungeon
	dungeon.dungeon_name = dungeon_data.dungeon_name
	dungeon.max_prog = dungeon_data.max_prog
	dungeon.progress = dungeon_data.progress
	dungeon.initialize(self)
	path = save_path.plus_file("map.tscn")
	var map = load(path).instance()
	dungeon.map.queue_free()
	map.add_squares_to_astar()
	map.connect_squares()
	map.connect("move_to_square", dungeon, "_on_Map_move_to_square")
	map.connect("show_tooltip", dungeon, "_on_Map_show_tooltip")
	map.connect("hide_tooltip", dungeon, "_on_Map_hide_tooltip")
	dungeon.add_child_below_node(dungeon.colorRect, map)
	dungeon.map = map
	dungeon.current_square = game_data.current_square
	dungeon.avatar.global_position = dungeon.map.get_pos(game_data.current_square) - Vector2(3, 3) + map.position

func delete_game(path) -> void:
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir(): file_name = dir.get_next()
			print("Deleting file: " + file_name)
			dir.remove(file_name)
			file_name = dir.get_next()
	dir.remove(path)

func check_error(path, error) -> void:
	if error != OK:
		print("There was an error writing the save %s to %s -> %s" % [core_data.profile_name, path, error])

func save_exists() -> bool:
	var file = File.new()
	var save_path = SAVE_DIR.plus_file(SAVE_NAME_TEMPLATE % self.profile_hash)
	var path = save_path.plus_file("data.tres")
	if !file.file_exists(path): return false
	var check = load(path)
	var version =  ProjectSettings.get_setting("application/config/version")
	print("game_data version: ", check.game_version)
	if check.game_version != version:
		delete_game(save_path)
		return false
	return file.file_exists(path)

func _on_StartGame_button_up() -> void:
	AudioController.click()
	title.hide()
#	demo.show()
	welcome.show()
	open_gem_shop.show()
	fade.play("FadeIn")
	yield(fade, "animation_finished")

func start_game() -> void:
	open_gem_shop.hide()
	for job in jobs:
		for perk in job.perks:
			if perk.trait and perk.cur_ranks == 1:
				traits.append(perk)
	if traits.size() > 0:
		trait_picker.initialize(self)
		trait_picker.show()
		fade.play("FadeIn")
		yield(fade, "animation_finished")
	else: new_game()

func new_game() -> void:
	var gear = char_select.equipped_gear.gear as Gear
	for trinket in gear.trinkets:
		print("Adding Trinket: ", trinket.name)
		player.add_trinket(trinket)
	for potion in gear.potions:
		print("Adding Potion: ", potion.name)
		player.potions.append(potion)
	var build = char_select.equipped_build.gear as Gear
	if build != null: player.set_build(build)
	dungeon.dungeon_name = ""
	dungeon.initialize(self)
	dungeon.new_map()
	enter_game()

func enter_game() -> void:
	AudioController.stop_bgm()
	refresh_dungeon()
	title.hide()
	welcome.hide()
	char_select.hide()
	open_gem_shop.hide()
	demo.hide()
	trait_picker.hide()
	blacksmith.initialize(self)
	shop.initialize(self)
	shop.connect("show_card", self, "show_card")
	shop.connect("hide_card", self, "hide_card")
	deck.initialize(self)
	deck.connect("show_card", self, "show_card")
	deck.connect("hide_card", self, "hide_card")
	battle.initialize(player)
	battle.toggle_auto_end(true)
	battle.connect("show_card", self, "show_card")
	battle.connect("hide_card", self, "hide_card")
	loot.initialize(self)
	dungeon.show()
	player.update_perk_bonuses()
	playerUI.initialize(self)
	playerUI.show()
	yield(get_tree().create_timer(0.5), "timeout")
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
	start_loot(enemy.gold, 3)
	yield(self, "looting_finished")
	if scene_to_hide != null: scene_to_hide.show()
	save_game()
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

func refresh_player(save: = true) -> void:
	playerUI.refresh()
	if save: save_game()

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

func _on_CharSelect_chose_class(job: Job) -> void:
	player = Actor.new()
	player.initialize(job)
	fade.play("FadeOut")
	yield(fade, "animation_finished")
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
	player.hp = player.max_hp

func _on_Arcane_button_up():
	AudioController.click()
	var n = "arcane_sorc"
	player = load("res://src/actions/sorcerer/" + n + ".tres")
	player.hp = player.max_hp

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
		settings_btn.texture_normal = gear_icon
		AudioController.back()
		settings.hide()

func _on_Dungeon_start_battle(enemy: EnemyActor) -> void:
	start_battle(dungeon, enemy)
	yield(self, "battle_finished")

func _on_Dungeon_start_loot(gold):
	# Chance to fight a Mimic!!
	var rand = randf()
	if rand < 0.05 * float(dungeon.progress) - 0.05:
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

func _on_Dungeon_event(event_name:String):
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	yield(get_tree().create_timer(0.25), "timeout")
	fade.play("FadeIn")
	event.show()
	var child = load("res://src/events/" + event_name + ".tscn").instance()
	event.add_child(child)
	child.initialize(self)

func _on_Dungeon_event_done():
	AudioController.steps()
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	event.hide()
	fade.play("FadeIn")
	save_game()

func _on_Dungeon_advance():
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	merchants.clear()
	if dungeon.progress == rooms:
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
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	loading = true
	player = playerUI.player
	load_game()
	enter_game()

func _on_WelcomeScreen_new():
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	var save_path = SAVE_DIR.plus_file(SAVE_NAME_TEMPLATE % self.profile_hash)
	delete_game(save_path)
	welcome.continue_button.disabled = true
	welcome.new_dialog.hide_instantly()
	char_select.initialize(self)
	welcome.hide()
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

func _on_Dungeon_shop(square_id: int):
	var actions: Array = []
	var others: Array = []
	if merchants.has(square_id):
		print("Found, loading")
		actions = merchants[square_id]["actions"]
#		others = merchants[square_id]["others"]
	else:
		print("Cannot find saved Shop, generating new one...")
		actions = loot.new_picker(dungeon.progress, 5)
#		others = loot.new_picker(progress, 5, true)
		merchants[square_id] = {"actions": actions}
#		merchants[square_id] = {"others": others}
	shop.display(actions, square_id)
#	shop.display_others(others)
	save_game()

func _on_Shop_shop_purchase(index: int, square_id: int):
	var items = merchants[square_id]["actions"] as Array
	items.remove(index)
	save_game()
	playerUI.refresh()

func _on_OpenGemShop_pressed():
	$OpenGemShop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.click()
	gem_shop.gem_qty = comma_sep(gems)
	gem_shop.show()
	yield(gem_shop, "done")
	$OpenGemShop.mouse_filter = Control.MOUSE_FILTER_STOP

func spend_gems(qty):
	self.gems -= qty

func comma_sep(number: int) -> String:
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod: res += ","
		res += string[i]
	return res

func _on_CharSelect_back():
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	char_select.hide()
	welcome.show()
	fade.play("FadeIn")

func _on_GemShop_buy_gems(qty):
	self.gems += qty
	char_select.refresh()

func _on_CharSelect_save_job(job):
	save_job_data(job)

func _on_TraitPicker_trait_back():
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	trait_picker.hide()
	fade.play("FadeIn")

func _on_TraitPicker_trait_choose(perk: Perk):
	if perk != null: add_active_trait(perk)
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	char_select.update_perk_bonuses()
	new_game()

func add_active_trait(perk: Perk) -> void:
	player.add_trait(perk.name)

# SETTERS / GETTERS

func set_gems(value) -> void:
	gems = value
	print("Saving gem data")
	core_data.gems = gems
	save_core_data()
	$OpenGemShop.text = comma_sep(value) + "  "
	gem_shop.gem_qty = comma_sep(gems)
