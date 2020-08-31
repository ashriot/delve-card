extends Node
class_name Game

signal battle_finished

export var player: Resource
export var rooms: = 5
export var mute: = false

onready var title: = $Title
onready var battle: = $Battle
onready var dungeon: = $Dungeon
onready var loot: = $Loot
onready var end_game: = $EndGame
onready var fade = $Fade/AnimationPlayer

var loot1: Array = []
var loot2: Array = []
var loot3: Array = []
var loot4: Array = []

func _ready() -> void:
	$Title/AnimationPlayer.play("FlashTap")
	randomize()
	AudioController.mute = mute
	AudioController.play_bgm("title")
	battle.initialize(player)
	dungeon.initialize()
	loot.initialize(player)
	title.show()
	battle.hide()
	loot.hide()
	dungeon.hide()
	end_game.hide()
	loot1 = get_loot(player.name, 1)
	loot2 = get_loot(player.name, 2)
	loot3 = get_loot(player.name, 3)
	loot4 = get_loot(player.name, 4)

func _on_StartGame_button_up() -> void:
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	title.hide()
	dungeon.show()
	fade.play("FadeIn")
	AudioController.play_bgm("dungeon")
	yield(fade, "animation_finished")

func _on_Dungeon_start_battle(enemy: Actor) -> void:
	start_battle(dungeon, enemy)
	yield(self, "battle_finished")
	if dungeon.progress == 9:
		print("done")
		end_game.show()
	else:
		dungeon.advance()

func start_battle(scene_to_hide: Node2D, enemy: Actor) -> void:
	fade.play("FadeOut")
	yield(fade, "animation_finished")
	scene_to_hide.hide()
	battle.show()
	battle.start(enemy)
	fade.play("FadeIn")
	yield(fade, "animation_finished")
	yield(battle, "battle_finished")
	fade.play("FadeOut")
	if battle.game_over:
		game_over()
		return
	AudioController.play_bgm("victory")
	yield(fade, "animation_finished")
	loot.setup(create_loot_list())
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

func create_loot_list() -> Array:
	var level = (1 + dungeon.progress / 3) as int
	print(level)
	var loot_list = []
	for i in range(3):
		var common = min(level, 4)
		var rare = min(level + 1, 4)
		var rand = randf()
		var chance = 0.25 * i
		var roll = rare if rand < chance else common
		var pick = pick_loot(roll)
		while loot_list.has(pick):
			print(pick)
			pick = pick_loot(roll)
		loot_list.append(pick)
	return loot_list

func pick_loot(rank: int) -> String:
	print("Rank: ", rank)
	var table: Array
	if rank == 1:
		table = loot1
	if rank == 2:
		table = loot2
	if rank == 3:
		table = loot3
	if rank == 4:
		table = loot4
	var rand = randi() % table.size()
	return table[rand]

func get_loot(player_name: String, rank: int) -> Array:
	var list = []
	var path = "res://src/actions/" + player_name + "/" + str(rank) + "/"
	print("Path: ", path)
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	
	for loot in files:
		list.append(load(path + loot))
	return list

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
