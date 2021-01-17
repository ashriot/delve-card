extends Control

var _Profile = preload("res://src/utils/Profile.tscn")

signal new
signal load_game
signal profile_chose(username)
signal save_core_data

onready var profile_btn: Button = $BG/Profile
onready var difficulty_btn: Button = $BG/Difficulty
onready var new_button: Button = $BG/NewGame
onready var continue_button: Button = $BG/ContinueGame
onready var new_dialog = $BG/NewDialog
onready var profiles = $Profiles
onready var create_profile = $Profiles/CreateDialog
onready var created_name = $Profiles/CreateDialog/Panel/LineEdit
onready var profile_box = $Profiles/ScrollContainer/ProfileBox
onready var exists = $Profiles/CreateDialog/Exists

var core_data: CoreData

var SAVE_KEY: String = "profile"

func initialize(game: Node) -> void:
	exists.hide()
	new_dialog.hide_instantly()
	core_data = game.core_data as CoreData
	profile_btn.text = core_data.profile_name
	if game.save_exists():
		continue_button.disabled = false
	else:
		continue_button.disabled = true
	if core_data.profile_name == "":
		profiles.show(false)
	else:
		profiles.hide_instantly()
		create_profile.hide_instantly()

func _on_ContinueGame_pressed():
	AudioController.click()
	emit_signal("load_game")

func _on_NewGame_pressed():
	AudioController.click()
	if continue_button.disabled:
		emit_signal("new")
	else:
		new_dialog.show(false)

func _on_Profile_pressed():
	AudioController.click()
	display_profiles()
	profiles.show(false)
	yield(profiles, "done")

func select_profile():
	profiles.hide(false)
	yield(profiles, "done")
	save_core_data()

func display_profiles():
	for child in profile_box.get_children():
		child.queue_free()
	for prof in core_data.profiles:
		var profile = _Profile.instance()
		profile.initialize(prof)
		profile.connect("chose", self, "profile_chose")
		profile.connect("deleted", self, "profile_deleted")
		profile_box.add_child(profile)

func profile_chose(username: String) -> void:
	profile_btn.text = username
	core_data.profile_name = username
	emit_signal("profile_chose", username)
	select_profile()

func profile_deleted(username: String) -> void:
	print("Deleted ", username)
	core_data.profiles.erase(username)
	save_core_data()
	display_profiles()

func _on_NewProfile_pressed():
	$Profiles/CreateDialog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.click()
	create_profile.show(false)
	created_name.grab_focus()
	yield(create_profile, "done")
	$Profiles/CreateDialog.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_NewProfileBack_pressed():
	$Profiles/CreateDialog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.back()
	create_profile.hide(false)
	yield(create_profile, "done")
	$Profiles/CreateDialog.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_OK_pressed():
	var found = false
	for profile in core_data.profiles:
		if profile == created_name.text:
			found = true
			exists.show()
			$Profiles/CreateDialog/Exists/Timer.start(2.0)
			break
	if found:
		AudioController.back()
		return
	AudioController.click()
	core_data.profiles.append(created_name.text)
	core_data.profile_name = created_name.text
	save_core_data()
	display_profiles()
	$Profiles/CreateDialog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	create_profile.hide(false)
	yield(create_profile, "done")
	created_name.text = ""
	$Profiles/CreateDialog.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_LineEdit_text_changed(new_text):
	var result = new_text.length() < 2
	$Profiles/CreateDialog/Panel/OK.disabled = result
	$Profiles/CreateDialog/Min.modulate.a = 1.0 if result else 0.25

func save_core_data():
	emit_signal("save_core_data")

func _on_Timer_timeout():
	exists.hide()

func _on_NewBack_pressed():
	$BG/NewDialog/Panel/NewBack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.back()
	new_dialog.hide(false)
	yield(new_dialog, "done")
	$BG/NewDialog/Panel/NewBack.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_NewOK_pressed():
	$BG/NewDialog/Panel/NewOK.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.click()
	emit_signal("new")
	$BG/NewDialog/Panel/NewOK.mouse_filter = Control.MOUSE_FILTER_STOP
