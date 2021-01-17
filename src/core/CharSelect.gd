extends Node2D

signal chose_class(name)

onready var _Perk: = preload("res://src/player/Perk.tscn")

onready var next_btn: = $BG/Prev
onready var prev_btn: = $BG/Next
onready var perks: = $Perks
onready var perks_banner: = $Perks/Banner/ClassPerks
onready var perks_list: = $Perks/BG2/Container/Perks
onready var perk_panel: = $Perks/BG2/Details
onready var perk_title: = $Perks/BG2/Details/Title
onready var perk_desc: = $Perks/BG2/Details/Desc
onready var perk_sprite: = $Perks/BG2/Details/Title/Sprite
onready var perk_ranks: = $Perks/BG2/Details/Ranks
onready var rank_up: = $Perks/BG2/Details/RankUp
onready var rank_cost: = $Perks/BG2/Details/RankUp/Cost
onready var rank_gem: = $Perks/BG2/Details/RankUp/Cost/Sprite
onready var job_name: = $BG/JobName
onready var job_desc: = $BG/Desc
onready var job_sprite: = $BG/Sprite
onready var perk_count: = $BG/Perks/Amt

var selected_perk: PerkButton setget set_selected_perk

var jobs: Array
var cur_job: Job

func _ready() -> void:
	pass

func initialize(_jobs: Array) -> void:
	perks.hide_instantly()
	jobs = _jobs
	cur_job = jobs[0] as Job
	setup_perks()
	display_job_data()
	clear_perk()

func display_job_data() -> void:
	job_name.text = cur_job.name
	perks_banner.text = cur_job.name + "'s" + " Perks"
	job_desc.text = cur_job.desc
	job_sprite.frame = cur_job.sprite_id
	var count = get_perk_count()
	perk_count.text = str(count[0]) + "/" + str(count[1])

func display_perk(perk: PerkButton) -> void:
	perk_title.text = perk.text
	perk_desc.text = perk.desc
	perk_ranks.text = perk.ranks
	if perk.perk.cur_ranks < perk.perk.max_ranks:
		rank_up.text = "Rank Up ->" + str(perk.perk.cur_ranks + 1)
		rank_cost.text = comma_sep(perk.perk.cost * (perk.perk.cur_ranks + 1))
		rank_up.disabled = false
		rank_gem.show()
	else:
		rank_up.text = "Max rank!"
		rank_cost.text = ""
		rank_up.disabled = true
		rank_gem.hide()
	perk_panel.show()

func clear_perk() -> void:
	perk_title.text = ""
	perk_desc.text = ""
	perk_ranks.text = ""
	rank_up.text = ""
	rank_cost.text = ""
	rank_up.disabled = true
	rank_gem.hide()

func setup_perks() -> void:
	for perk in cur_job.perks:
		var new_perk = _Perk.instance()
		new_perk.initialize(perk)
		new_perk.connect("pressed", self, "_on_Perk_pressed", [new_perk])
		perks_list.add_child(new_perk)

func get_perk_count() -> Array:
	var count = [0, 0] as Array
	for perk in perks_list.get_children():
		count[0] += perk.perk.cur_ranks
		count[1] += perk.perk.max_ranks
	return count

func comma_sep(number: int) -> String:
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	return res

func _on_Perk_pressed(button) -> void:
	self.selected_perk = button

func _on_Button_down(button):
	button.get_parent().modulate.a = .66

func _on_Button_up(button):
	AudioController.click()
	button.get_parent().modulate.a = 1
	print("chose ", button.name)
	emit_signal("chose_class", button.name)

func _on_Back_pressed():
	$Perks/BG2/Back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.back()
	perks.hide(false)
	yield(perks, "done")
	$Perks/BG2/Back.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_Perks_pressed():
	$BG/Perks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.click()
	perks.show(false)
	yield(perks, "done")
	$BG/Perks.mouse_filter = Control.MOUSE_FILTER_STOP

func set_selected_perk(value: PerkButton) -> void:
	print(value.text)
	value.chosen = !value.chosen
	for child in perks_list.get_children():
		if child != value:
			child.chosen = false
	selected_perk = value if value.chosen else null
	if selected_perk == null:
		AudioController.back()
		clear_perk()
		return
	else:
		AudioController.click()
		display_perk(selected_perk)

func _on_RankUp_pressed():
	AudioController.click()
	selected_perk.rank_up()
	display_perk(selected_perk)
	var count = get_perk_count()
	perk_count.text = str(count[0]) + "/" + str(count[1])
