extends Node2D

signal chose_class(name)

onready var _Perk: = preload("res://src/player/Perk.tscn")

onready var next_btn: = $BG/Prev
onready var prev_btn: = $BG/Next
onready var perks: = $Perks
onready var perks_banner: = $Perks/Banner/ClassPerks
onready var perks_list: = $Perks/BG2/Container/Perks
onready var job_name: = $BG/JobName
onready var job_desc: = $BG/Desc
onready var job_sprite: = $BG/Sprite
onready var perk_count: = $BG/Perks/Amt

var jobs: Array
var cur_job: Job

func _ready() -> void:
	pass

func initialize(_jobs: Array) -> void:
	perks.hide_instantly()
	jobs = _jobs
	cur_job = jobs[0] as Job
	display_job_data()

func display_job_data() -> void:
	job_name.text = cur_job.name
	perks_banner.text = cur_job.name + "'s" + " Perks"
	job_desc.text = cur_job.desc
	job_sprite.frame = cur_job.sprite_id
	var count = get_perk_count()
	perk_count.text = str(count[0]) + "/" + str(count[1])

func get_perk_count() -> Array:
	var count = [0, 0] as Array
	for perk in cur_job.perks:
		count[0] += perk.cur_ranks
		count[1] += perk.max_ranks
		var new_perk = _Perk.instance()
		new_perk.initialize(perk)
		perks_list.add_child(new_perk)
		print(perk.name)
	return count

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
