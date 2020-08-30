extends Node2D

export var mute: = false
export var vol_bgm: = 0.0
export var vol_sfx: = 0.0

onready var bgm: = $bgm
onready var sfx1: = $sfx1
onready var sfx2: = $sfx2
onready var sfx3: = $sfx3
onready var sfx4: = $sfx4
onready var sfx5: = $sfx5

func _ready() -> void:
	set_bgm_volume()
	set_sfx_volume()

func play_bgm(name: String) -> void:
	if mute: return
	bgm.stream = load("res://assets/audio/bgm/" + name + ".ogg")
	bgm.play()

func play_sfx(name: String) -> void:
	if (!sfx1.playing):
		sfx1.stream = load("res://assets/audio/sfx/" + name + ".wav")
		sfx1.play()
	elif (!sfx2.playing):
		sfx2.stream = load("res://assets/audio/sfx/" + name + ".wav")
		sfx2.play()
	elif (!sfx3.playing):
		sfx3.stream = load("res://assets/audio/sfx/" + name + ".wav")
		sfx3.play()

func click() -> void:
	play_sfx("click")
	
func back() -> void:
	play_sfx("back")

func steps() -> void:
	play_sfx("footsteps")

func set_bgm_volume() -> void:
	bgm.volume_db = vol_bgm

func set_sfx_volume() -> void:
	sfx1.volume_db = vol_sfx
	sfx2.volume_db = vol_sfx
	sfx3.volume_db = vol_sfx
	sfx4.volume_db = vol_sfx
	sfx5.volume_db = vol_sfx
