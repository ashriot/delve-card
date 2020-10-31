extends Node

const SaveGame = preload("res://src/utils/SaveGame.gd")
# TODO: Use project setting to save to res://debug vs user://
var SAVE_FOLDER: String = "res://debug/save"
var SAVE_NAME_TEMPLATE: String = "save_%03d.tres"


func save(id: int):
	print("saving game")
	# Passes a SaveGame resource to all nodes to save data from
	# and writes it to the disk
	var save_game := SaveGame.new()
	save_game.game_version = ProjectSettings.get_setting("application/config/version")
	for node in get_tree().get_nodes_in_group("save"):
		node.save(save_game)

	var directory: Directory = Directory.new()
	if not directory.dir_exists(SAVE_FOLDER):
		directory.make_dir_recursive(SAVE_FOLDER)

	var save_path = SAVE_FOLDER.plus_file(SAVE_NAME_TEMPLATE % id)
	var error: int = ResourceSaver.save(save_path, save_game)
	if error != OK:
		print("There was an issue writing the save %s to %s" % [id, save_path])

func exists(id: int) -> bool:
	var save_file_path: String = SAVE_FOLDER.plus_file(SAVE_NAME_TEMPLATE % id)
	var file: File = File.new()
	if not file.file_exists(save_file_path):
		print("Save file %s doesn't exist" % save_file_path)
		return false
	return true

func load(id: int):
	print("loading game")
	# Reads a saved game from the disk and delegates loading
	# to the individual nodes to load
	if not exists(id): return

	var save_file_path: String = SAVE_FOLDER.plus_file(SAVE_NAME_TEMPLATE % id)
	var save_game: Resource = load(save_file_path)
	for node in get_tree().get_nodes_in_group("save"):
		node.load(save_game)
