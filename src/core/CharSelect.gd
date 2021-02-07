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
onready var gear_btn: = $BG/Gears
onready var build_btn: = $BG/Builds
onready var perks_list: = $Perks/BG2/Container/Perks
onready var perks_banner: = $Perks/Banner/ClassPerks
onready var gears_list: = $Gears/BG2/Container/Gears
onready var gears_banner: = $Gears/Banner/ClassGears
onready var builds_list: = $Builds/BG2/Container/Builds
onready var builds_banner: = $Builds/Banner/ClassBuilds
onready var perk_detail_panel: = $Perks/Details
onready var perk_detail_title: = $Perks/Details/Title
onready var perk_detail_desc: = $Perks/Details/Desc
onready var perk_detail_sprite: = $Perks/Details/Title/Sprite
onready var perk_detail_ranks: = $Perks/Details/Ranks
onready var rank_up: = $Perks/Details/RankUp
onready var rank_cost: = $Perks/Details/RankUp/Cost
onready var gear_detail_panel: = $Gears/Details
onready var gear_detail_title: = $Gears/Details/Title
onready var gear_detail_desc: = $Gears/Details/Desc
onready var gear_detail_sprite: = $Gears/Details/Title/Locked
onready var gear_detail_choose: = $Gears/Details/Unlock
onready var gear_cost: = $Gears/Details/Unlock/Cost
onready var build_panel: = $Builds/Details
onready var build_title: = $Builds/Details/Title
onready var build_desc: = $Builds/Details/Desc
onready var build_sprite: = $Builds/Details/Title/Locked
onready var build_choose: = $Builds/Details/UnlockBuild
onready var build_cost: = $Builds/Details/UnlockBuild/Cost
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
var selected_gear: GearButton setget set_selected_gear
var selected_build: GearButton setget set_selected_build
var equipped_gear: GearButton
var equipped_build: GearButton

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
		for gear in gears_list.get_children():
			gear.connect("pressed", self, "_on_Gear_pressed", [gear])
		for build in builds_list.get_children():
			build.connect("pressed", self, "_on_Build_pressed", [build])
	equipped_gear = gears_list.get_child(0)
	equipped_build = builds_list.get_child(0)
	equipped_gear.equip()
	equipped_build.equip()
	perks.hide_instantly()
	gears.hide_instantly()
	builds.hide_instantly()
	display_job_stats()
	setup_perks()
	setup_gears()
	setup_builds()
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
	perks_banner.text = "Lv. " + str(cur_job.level) + " " + cur_job.name + " Perks"
	gears_banner.text = "Lv. " + str(cur_job.level) + " " + cur_job.name + " Gear"
	builds_banner.text = "Lv. " + str(cur_job.level) + " " + cur_job.name + " Builds"
	job_desc.text = cur_job.desc
	job_sprite.frame = cur_job.sprite_id
	setup_perk_button()

func setup_perk_button() -> void:
	if cur_job == null: return
	delve.disabled = !cur_job.unlocked
	if cur_job.unlocked:
		unlock_cost.hide()
		gear_btn.show()
		build_btn.show()
		build_btn.text = equipped_build.text

		if cur_job.level < 2:
			gear_btn.icon = lock
			gear_btn.disabled = true
			gear_btn.text = "Gear Unlocked at Lv. 2"
		else:
			gear_btn.icon = gear_icon
			gear_btn.disabled = false
			gear_btn.text = equipped_gear.text
		if cur_job.level < 3:
			perk_count.text = ""
			perk_button.icon = lock
			perk_button.disabled = true
			perk_button.text = "Perks Unlocked at Lv. 3"
		else:
			perk_button.icon = perk_icon
			perk_button.disabled = false
			perk_button.text = "Perks"
			var count = get_perk_count()
			perk_count.text = str(count[0]) + "/" + str(count[1])
			perk_count.show()
	else:
		perk_button.icon = lock
		perk_button.disabled = game.gems < 1000
		perk_button.text = "Unlock"
		unlock_cost.text = comma_sep(1000)
		perk_count.hide()
		gear_btn.hide()
		build_btn.hide()
		unlock_cost.show()

func xp_to_level() -> int:
	return (cur_job.level + 1) * 100

func refresh_perk() -> void:
	display_perk(selected_perk)
	setup_perk_button()

func display_perk(perk: PerkButton) -> void:
	perk_detail_title.text = perk.text
	perk_detail_desc.bbcode_text = perk.desc
	perk_detail_sprite.frame = perk.perk.tier
	perk_detail_ranks.text = perk.ranks
	rank_up.disabled = true
	rank_cost.text = comma_sep(perk.cost)
	rank_cost.modulate.a = 0.5
	rank_cost.show()
	if perk.level_req > cur_job.level:
		rank_up.text = "Requires Lv. " + str(perk.level_req)
	else:
		if perk.perk.cur_ranks < perk.perk.max_ranks:
			rank_up.disabled = perk.cost > game.gems
			rank_cost.modulate.a = 0.5 if game.gems < perk.cost else 1.0
			rank_up.text = "Rank up " + str(perk.perk.cur_ranks) + " -> " + str(perk.perk.cur_ranks + 1)
		else:
			rank_up.text = "Max rank!"
			rank_cost.hide()

func display_gear(gearButton: GearButton) -> void:
	gear_detail_title.text = gearButton.text
	gear_detail_desc.bbcode_text = gearButton.desc
	gear_detail_choose.disabled = false
	gear_cost.text = comma_sep(gearButton.cost)
	gear_cost.modulate.a = 0.5
	gear_cost.show()
	gear_detail_sprite.show()
	if gearButton.level_req > cur_job.level:
		gear_detail_choose.text = "Requires Lv. " + str(gearButton.level_req)
		gear_detail_choose.disabled = true
	else:
		if !gearButton.gear.unlocked:
			gear_detail_choose.disabled = gearButton.cost > game.gems
			gear_cost.modulate.a = 0.5 if game.gems < gearButton.cost else 1.0
			gear_detail_choose.text = "Unlock"
		else:
			gear_detail_sprite.hide()
			gear_cost.hide()
			if gearButton == equipped_gear:
				gear_detail_choose.text = "Equipped"
				gear_detail_choose.disabled = true
			else:
				gear_detail_choose.text = "Equip"
				gear_detail_choose.disabled = false

func display_build(gearButton: GearButton) -> void:
	build_title.text = gearButton.text
	build_desc.bbcode_text = gearButton.desc
	build_choose.disabled = false
	build_cost.text = comma_sep(gearButton.cost)
	build_cost.modulate.a = 0.5
	build_cost.show()
	build_sprite.show()
	if gearButton.level_req > cur_job.level:
		build_choose.text = "Requires Lv. " + str(gearButton.level_req)
		build_choose.disabled = true
	else:
		if !gearButton.gear.unlocked:
			build_choose.disabled = gearButton.cost > game.gems
			build_cost.modulate.a = 0.5 if game.gems < gearButton.cost else 1.0
			build_choose.text = "Unlock"
		else:
			build_sprite.hide()
			build_cost.hide()
			if gearButton == equipped_build:
				build_choose.text = "Selected"
				build_choose.disabled = true
			else:
				build_choose.text = "Select"
				build_choose.disabled = false

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

func setup_gears() -> void:
	print("setup_gears()")
	var first = gears_list.get_child(0)
	for i in range(gears_list.get_child_count()):
		var new_gear = gears_list.get_child(i)
		if i >= cur_job.gears.size():
			new_gear.clear()
			continue
		new_gear.initialize(cur_job.gears[i])

func setup_builds() -> void:
	print("setup_builds()")
	var first = builds_list.get_child(0)
	for i in range(builds_list.get_child_count()):
		var new_build = builds_list.get_child(i)
		if i >= cur_job.builds.size():
			new_build.clear()
			continue
		new_build.initialize(cur_job.builds[i])

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

func set_selected_gear(value: GearButton) -> void:
	if value.chosen: return
	AudioController.click()
	if selected_gear != null:
		selected_gear.chosen = false
	value.chosen = true
	selected_gear = value
	display_gear(selected_gear)

func set_selected_build(value: GearButton) -> void:
	print("displaying build")
	if value.chosen: return
	AudioController.click()
	if selected_build != null:
		selected_build.chosen = false
	value.chosen = true
	selected_build = value
	display_build(selected_build)

func apply_perk() -> void:
	emit_signal("save_job", cur_job)
	display_job_stats()

func update_perk_bonuses() -> void:
	cur_job.update_perk_bonuses()

func _on_Perk_pressed(button) -> void:
	self.selected_perk = button

func _on_Gear_pressed(button) -> void:
	self.selected_gear = button

func _on_Build_pressed(button) -> void:
	self.selected_build = button

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

func _on_Gears_pressed():
	$BG/Gears.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.click()
	self.selected_gear = equipped_gear
	gears.show(false)
	yield(gears, "done")
	$BG/Gears.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_Builds_pressed():
	$BG/Builds.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.click()
	self.selected_build = equipped_build
	builds.show(false)
	yield(builds, "done")
	$BG/Builds.mouse_filter = Control.MOUSE_FILTER_STOP

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
	setup_gears()
	setup_builds()
	display_job_data()

func _on_Next_pressed():
	AudioController.click()
	var index = (jobs.find(cur_job) + 1) % jobs.size()
	cur_job = jobs[index]
	display_job_stats()
	setup_perks()
	setup_gears()
	setup_builds()
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

func _on_Unlock_pressed():
	AudioController.confirm()
	if selected_gear.gear.unlocked:
		equipped_gear.unequip()
		equipped_gear = selected_gear
		gear_btn.text = selected_gear.gear.name
		selected_gear.equip()
		gear_detail_choose.text = "Equipped"
		gear_detail_choose.disabled = true
	else:
		game.spend_gems(selected_gear.cost)
		selected_gear.unlock()
		emit_signal("save_job", cur_job)
		display_gear(selected_gear)


func _on_UnlockBuild_pressed():
	AudioController.confirm()
	if selected_build.gear.unlocked:
		equipped_build.unequip()
		equipped_build = selected_build
		build_btn.text = selected_build.gear.name
		selected_build.equip()
		build_choose.text = "Selected"
		build_choose.disabled = true
	else:
		game.spend_gems(selected_build.cost)
		selected_build.unlock()
		emit_signal("save_job", cur_job)
		display_build(selected_build)
