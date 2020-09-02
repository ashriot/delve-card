extends Node2D

signal chose_class(name)

onready var fighter_btn = $ColorRect/VBoxContainer/Fighter/Fighter
onready var sorcerer_btn = $ColorRect/VBoxContainer/Sorcerer/Sorcerer
onready var thief_btn = $ColorRect/VBoxContainer/Thief/Thief

func _ready() -> void:
	fighter_btn.connect("button_up", self, "_on_Button_up", [fighter_btn])
	fighter_btn.connect("button_down", self, "_on_Button_down", [fighter_btn])
	sorcerer_btn.connect("button_up", self, "_on_Button_up", [sorcerer_btn])
	sorcerer_btn.connect("button_down", self, "_on_Button_down", [sorcerer_btn])
#	thief_btn.connect("button_up", self, "_on_Button_up", [thief_btn])
#	thief_btn.connect("button_down", self, "_on_Button_down", [thief_btn])

func _on_Button_down(button):
	button.get_parent().modulate.a = .66

func _on_Button_up(button):
	AudioController.click()
	button.get_parent().modulate.a = 1
	print("chose ", button.name)
	emit_signal("chose_class", button.name)
