extends Node2D

var _TraitButton = preload("res://src/player/TraitButton.tscn")

onready var trait_list = $BG/Container/Traits

var traits: Array

func _ready():
	hide()

func initialize(game: Game) -> void:
	traits = []
	var jobs = game.jobs
	for job in jobs:
		for perk in job.perks:
			if perk.trait and perk.cur_ranks == 1:
				traits.append(perk)
	print(traits)
	for trait in traits:
		var btn = _TraitButton.instance()
		btn.initialize(trait)
		trait_list.add_child(btn)
