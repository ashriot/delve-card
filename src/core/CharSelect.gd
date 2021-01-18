extends Node2D

signal chose_class(name)
signal spent_gems(qty)
signal back

onready var _Perk: = preload("res://src/player/Perk.tscn")

# STATS
onready var hp: = $BG/Stats/HP/Label
onready var mp: = $BG/Stats/MP/Label
onready var ac: = $BG/Stats/AC/Label
onready var st: = $BG/Stats/ST/Label
onready var gp: = $BG/Stats/GP/Label

onready var prev_btn: = $BG/Prev
onready var next_btn: = $BG/Next
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
onready var level: = $BG/XpBar/Level
onready var xp_bar: = $BG/XpBar
onready var xp: = $BG/XpBar/XP
onready var job_desc: = $BG/Desc
onready var job_sprite: = $BG/Portrait
onready var perk_count: = $BG/Perks/Amt

var selected_perk: PerkButton setget set_selected_perk

var game: Game
var jobs: Array
var cur_job: Job

func initialize(_game: Game, _jobs: Array) -> void:
	perks.hide_instantly()
	game = _game
	jobs = _jobs
	cur_job = jobs[0] as Job
	display_job_stats()
	setup_perks()
	display_job_data()
	clear_perk()

func display_job_stats() -> void:
	hp.text = str(cur_job.max_hp)
	mp.text = str(cur_job.initial_mp)
	ac.text = str(cur_job.initial_ac)
	st.text = str(cur_job.max_ap)
	gp.text = str(cur_job.starting_gold)

func display_job_data() -> void:
	level.text = "Lv. " + str(cur_job.level) + " " + cur_job.name
	var xp_to_level = xp_to_level()
	if cur_job.level < 10: xp.text = comma_sep(cur_job.xp) + "/" + comma_sep(xp_to_level) + " XP"
	else: xp.text = "Max Level"
	xp_bar.max_value = xp_to_level
	xp_bar.value = cur_job.xp if cur_job.level < 10 else 1100
	perks_banner.text = "Level " + str(cur_job.level) + " " + cur_job.name + " Perks"
	job_desc.text = cur_job.desc
	job_sprite.frame = cur_job.sprite_id
	var count = get_perk_count()
	perk_count.text = str(count[0]) + "/" + str(count[1])

func xp_to_level() -> int:
	return (cur_job.level + 1) * 100

func display_perk(perk: PerkButton) -> void:
	perk_panel.modulate.a = 1
	perk_title.text = perk.text
	perk_desc.text = perk.desc
	perk_ranks.text = perk.ranks
	rank_up.disabled = true
	rank_cost.text = comma_sep(perk.cost)
	rank_cost.modulate.a = 0.5
	rank_gem.show()
	if perk.get_index() >= cur_job.level:
		rank_up.text = "Requires level " + str(perk.get_index() + 1)
	else:
		if perk.perk.cur_ranks < perk.perk.max_ranks:
			rank_up.text = "Rank " + str(perk.perk.cur_ranks) + " -> " + str(perk.perk.cur_ranks + 1)
			rank_up.disabled = perk.cost > game.gems
			rank_cost.modulate.a = 0.5 if game.gems < perk.cost else 1
		else:
			rank_up.text = "Max rank!"
			rank_cost.text = ""
			rank_gem.hide()
	perk_panel.show()

func clear_perk() -> void:
	perk_panel.modulate.a = 0.25
	perk_title.text = ""
	perk_desc.text = ""
	perk_ranks.text = ""
	rank_up.text = ""
	rank_cost.text = ""
	rank_up.disabled = true
	rank_gem.hide()

func clear_perks_list() -> void:
	for child in perks_list.get_children():
		child.free()

func setup_perks() -> void:
	clear_perks_list()
	for perk in cur_job.perks:
		var new_perk = _Perk.instance()
		new_perk.initialize(perk)
		new_perk.connect("pressed", self, "_on_Perk_pressed", [new_perk])
		perks_list.add_child(new_perk)
		if new_perk.get_index() >= cur_job.level:
			new_perk.modulate.r = 0.5
			new_perk.modulate.g = 0.5
			new_perk.modulate.b = 0.5

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

func set_selected_perk(value: PerkButton) -> void:
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

func apply_perk(perk: Perk) -> void:
	if perk.name == "Toughness": cur_job.max_hp += perk.amts[0]
	if perk.name == "Wealth": cur_job.starting_gold += perk.amts[0]
	display_job_stats()

func _on_Perk_pressed(button) -> void:
	self.selected_perk = button

func _on_Button_down(button):
	button.get_parent().modulate.a = .66

func _on_Button_up(button):
	AudioController.click()
	button.get_parent().modulate.a = 1
	print("chose ", button.name)
	emit_signal("chose_class", button.name)

func _on_PerksBack_pressed():
	$Perks/BG2/PerksBack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.back()
	perks.hide(false)
	yield(perks, "done")
	clear_perk()
	for child in perks_list.get_children():
		child.chosen = false
	$Perks/BG2/PerksBack.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_Perks_pressed():
	$BG/Perks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.click()
	perks.show(false)
	yield(perks, "done")
	$BG/Perks.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_RankUp_pressed():
	AudioController.confirm()
	game.spend_gems(selected_perk.cost)
	selected_perk.rank_up()
	display_perk(selected_perk)
	apply_perk(selected_perk.perk)
	var count = get_perk_count()
	perk_count.text = str(count[0]) + "/" + str(count[1])

func _on_Back_pressed():
	AudioController.back()
	emit_signal("back")
	clear_perk()

func _on_Prev_pressed():
	AudioController.click()
	var index = jobs.find(cur_job) - 1
	cur_job = jobs[index]
	print(index)
	display_job_stats()
	setup_perks()
	display_job_data()
	clear_perk()

func _on_Next_pressed():
	AudioController.click()
	var index = (jobs.find(cur_job) + 1) % jobs.size()
	cur_job = jobs[index]
	print(index)
	display_job_stats()
	setup_perks()
	display_job_data()
	clear_perk()
