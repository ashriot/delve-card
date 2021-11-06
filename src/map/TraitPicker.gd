extends Node2D

signal trait_back
signal trait_choose(perk)

var _TraitButton = preload("res://resources/player/TraitButton.tscn")

onready var trait_list = $BG/Container/Traits
onready var perk_title = $BG/Info/Title
onready var perk_desc: = $BG/Info/Desc
onready var icon: = $BG/Info/Sprite
onready var choose: = $BG/Choose

var traits: Array
var selected_trait: TraitButton setget set_selected_trait
var progress = 0

func _ready():
	hide()

func initialize(game: Game) -> void:
	connect("trait_choose", game, "_on_TraitPicker_trait_choose")
	progress = game.dungeon.progress
	perk_title.text = ""
	perk_desc.text = ""
	choose.disabled = true
	traits = game.traits
	for trait in traits:
		var cutoff = progress / 2 + 1
		if trait.tier > cutoff: continue
		var btn = _TraitButton.instance()
		btn.initialize(self, trait)
		trait_list.add_child(btn)
	var first = trait_list.get_child(0)
	selected_trait = first
	first.chosen = true
	display_trait(selected_trait)

func _on_TraitButton_clicked(btn: TraitButton) -> void:
	print ("Clicked trait: ", btn.perk.name)
	self.selected_trait = btn

func set_selected_trait(value: TraitButton) -> void:
	selected_trait.chosen = false
	value.chosen = true
	selected_trait = value
	display_trait(selected_trait)

func display_trait(perk: TraitButton) -> void:
	perk_title.text = perk.text
	perk_desc.text = perk.desc
	icon.frame = perk.perk.tier
	choose.disabled = false

func _on_Back_pressed():
	AudioController.back()
	emit_signal("trait_back")

func _on_Choose_pressed():
	AudioController.confirm()
	emit_signal("trait_choose", selected_trait.perk)
