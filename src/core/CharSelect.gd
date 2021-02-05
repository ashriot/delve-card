extends Node2D

signal chose_class(job)
signal back
signal save_job(job)

var lock = preload("res://assets/images/ui/lock.png")
var perk_icon = preload("res://assets/images/ui/talents.png")
var gear_icon = preload("res://assets/images/ui/pack.png")

# STATS
onready var hp: = $BG/Stats/HP/Label
onready var mp: = $BG/Stats/MP/Label
onready var ac: = $BG/Stats/AC/Label
onready var st: = $BG/Stats/ST/Label
onready var gp: = $BG/Stats/GP/Label

onready var prev_btn: = $BG/Prev
onready var next_btn: = $BG/Next
onready var perks: = $Perks
onready var gears: = $Gears
onready var builds: = $Builds
onready var gear: = $BG/Gear
onready var build: = $BG/Build
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
onready var perk_button: = $BG/Perks
onready var perk_count: = $BG/Perks/Amt
onready var unlock_cost: = $BG/Perks/Price

onready var delve: = $BG/Delve

var selected_perk: PerkButton setget set_selected_perk

var game: Game
var jobs: Array
var cur_job: Job

var initialized: = false

func initialize(_game: Game) -> void:
	print("initializing char select")
	if !initialized:
		game = _game
		jobs = _game.jobs
		cur_job = jobs[0] as Job
		for perk in perks_list.get_children():
			perk.connect("pressed", self, "_on_Perk_pressed", [perk])
	perks.hide_instantly()
	gears.hide_instantly()
	builds.hide_instantly()
	display_job_stats()
	setup_perks()
	display_job_data()
	initialized = true

func display_job_stats() -> void:
	update_perk_bonuses()
	hp.text = str(cur_job.hp())
	mp.text = str(cur_job.mp())
	ac.text = str(cur_job.ac())
	st.text = str(cur_job.st())
	gp.text = str(cur_job.gold())

func display_job_data() -> void:
	$BG/CharLock.hide()
	level.text = "Lv. " + str(cur_job.level) + " " + cur_job.name
	var xp_to_level = xp_to_level()
	if !cur_job.unlocked:
		xp.text = "LOCKED"
		$BG/CharLock.show()
	elif cur_job.level < 10: xp.text = comma_sep(cur_job.xp) + "/" + comma_sep(xp_to_level) + " XP"
	else: xp.text = "Max Level"
	xp_bar.max_value = xp_to_level
	xp_bar.value = cur_job.xp if cur_job.level < 10 else 1100
	perks_banner.text = "Level " + str(cur_job.level) + " " + cur_job.name + " Perks"
	job_desc.text = cur_job.desc
	job_sprite.frame = cur_job.sprite_id
	setup_perk_button()

func setup_perk_button() -> void:
	if cur_job == null: return
	delve.disabled = !cur_job.unlocked
	if cur_job.unlocked:
		unlock_cost.hide()
		gear.show()
		build.show()
		if cur_job.level < 2:
			gear.icon = lock
			gear.disabled = true
			gear.text = "Gear Unlocked at Lv. 2"
		else:
			gear.icon = gear_icon
			gear.disabled = true
			gear.text = "None"
		if cur_job.level < 3:
			perk_count.text = ""
			perk_button.icon = lock
			perk_button.disabled = true
			perk_button.text = "Perks Unlocked at Lv. 3"
		else:
			perk_button.icon = perk_icon
			perk_button.disabled = false
			perk_button.text = "Check Perks"
			var count = get_perk_count()
			perk_count.text = str(count[0]) + "/" + str(count[1])
			perk_count.show()
	else:
		perk_button.icon = lock
		perk_button.disabled = game.gems < 1000
		perk_button.text = "Unlock"
		unlock_cost.text = comma_sep(1000)
		perk_count.hide()
		gear.hide()
		build.hide()
		unlock_cost.show()

func xp_to_level() -> int:
	return (cur_job.level + 1) * 100

func refresh_perk() -> void:
	display_perk(selected_perk)
	setup_perk_button()

func display_perk(perk: PerkButton) -> void:
	perk_title.text = perk.text
	perk_desc.text = perk.desc
	perk_sprite.frame = perk.perk.tier
	perk_ranks.text = perk.ranks
	rank_up.disabled = true
	rank_cost.text = comma_sep(perk.cost)
	rank_cost.modulate.a = 0.5
	rank_gem.show()
	if perk.level_req > cur_job.level:
		rank_up.text = "Requires level " + str(perk.level_req)
	else:
		if perk.perk.cur_ranks < perk.perk.max_ranks:
			rank_up.disabled = perk.cost > game.gems
			rank_cost.modulate.a = 0.5 if game.gems < perk.cost else 1.0
			rank_up.text = "Rank up " + str(perk.perk.cur_ranks) + " -> " + str(perk.perk.cur_ranks + 1)
		else:
			rank_up.text = "Max rank!"
			rank_cost.text = ""
			rank_gem.hide()

func setup_perks() -> void:
	for i in range(perks_list.get_child_count()):
		var new_perk = perks_list.get_child(i)
		if i >= cur_job.perks.size():
			new_perk.clear()
			continue
		new_perk.initialize(cur_job.perks[i])
		if new_perk.level_req > cur_job.level: new_perk.fade()
		else: new_perk.opaque()
	var first = perks_list.get_child(0)
	first.chosen = true
	selected_perk = first
	display_perk(first)

func get_perk_count() -> Array:
	var count = [0, 0] as Array
	for perk in perks_list.get_children():
		if perk.perk == null: break
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
	if value.chosen: return
	AudioController.click()
	selected_perk.chosen = false
	value.chosen = true
	selected_perk = value
	display_perk(selected_perk)

func apply_perk() -> void:
	emit_signal("save_job", cur_job)
	display_job_stats()

func update_perk_bonuses() -> void:
	cur_job.update_perk_bonuses()

func _on_Perk_pressed(button) -> void:
	self.selected_perk = button

func _on_Perks_pressed():
	$BG/Perks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if cur_job.unlocked:
		AudioController.click()
		perks.show(false)
		yield(perks, "done")
	else:
		AudioController.confirm()
		game.spend_gems(1000)
		cur_job.unlocked = true
		emit_signal("save_job", cur_job)
		display_job_data()
		refresh_perk()
	$BG/Perks.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_RankUp_pressed():
	AudioController.confirm()
	game.spend_gems(selected_perk.cost)
	selected_perk.rank_up()
	display_perk(selected_perk)
	apply_perk()
	var count = get_perk_count()
	perk_count.text = str(count[0]) + "/" + str(count[1])

func _on_Back_pressed():
	AudioController.back()
	emit_signal("back")

func _on_Prev_pressed():
	AudioController.click()
	var index = jobs.find(cur_job) - 1
	cur_job = jobs[index]
	display_job_stats()
	setup_perks()
	display_job_data()

func _on_Next_pressed():
	AudioController.click()
	var index = (jobs.find(cur_job) + 1) % jobs.size()
	cur_job = jobs[index]
	display_job_stats()
	setup_perks()
	display_job_data()

func _on_Delve_pressed():
	AudioController.confirm()
	print("chose ", cur_job.name)
	emit_signal("chose_class", cur_job)

func _on_PerksBack_pressed():
	$Perks/BG2/PerksBack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.back()
	perks.hide(false)
	yield(perks, "done")
	$Perks/BG2/PerksBack.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_Gear_pressed():
	$BG/Gear.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.click()
	gears.show(false)
	yield(gears, "done")
	$BG/Gear.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_Build_pressed():
	$BG/Build.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.click()
	builds.show(false)
	yield(builds, "done")
	$BG/Build.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_GearsBack_pressed():
	$Gears/BG2/GearsBack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.back()
	gears.hide(false)
	yield(gears, "done")
	$Gears/BG2/GearsBack.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_BuildsBack_pressed():
	$Builds/BG2/BuildsBack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.back()
	builds.hide(false)
	yield(builds, "done")
	$Builds/BG2/BuildsBack.mouse_filter = Control.MOUSE_FILTER_STOP
