extends ColorRect
class_name Event

signal done

export var title: String
export(String, MULTILINE) var desc
export var person: = -1
export var scene: = -1 setget set_scene
export var item: = -1
export var choice_1: String
export var choice_2: String
export var choice_3: String
export var choice_4: String

onready var btn1: = $Options/Choice1
onready var btn2: = $Options/Choice2
onready var btn3: = $Options/Choice3
onready var btn4: = $Options/Choice4

onready var hp: = $HPBanner/HP
onready var gp: = $HPBanner/GP

onready var tween: = $Desc/Tween

var playerUI: PlayerUI
var you_frame: int
var stage: = 0
var gold: = 0 setget set_gold, get_gold

func _ready():
	print("readying event")
	$Banner/Label.text = title
	$Desc.text = desc
	$Options/Choice1.text = choice_1
	$Options/Choice2.text = choice_2
	$Options/Choice3.text = choice_3
	$Options/Choice4.text = choice_4
	$Desc.percent_visible = 0

	if choice_1 == "": $Options/Choice1.hide()
	if choice_2 == "": $Options/Choice2.hide()
	if choice_3 == "": $Options/Choice3.hide()
	if choice_4 == "": $Options/Choice4.hide()

	if person > -1: $Person.frame = person
	else: $Person.hide()
	if scene > -1: $Scene.frame = scene
	else:
		$Scene.hide()
		$SceneBG.hide()
	if item > -1: $Item.frame = item
	else: $Item.hide()
	yield(get_tree().create_timer(0.25), "timeout")

func initialize(game: Game) -> void:
	connect("done", game, "_on_Dungeon_event_done")
	playerUI = game.playerUI
	gold = playerUI.player.gold
	gp.text = str(self.gold)
	hp.bbcode_text = playerUI.get_hp_text()
	$Person/You.frame = playerUI.player.portrait_id
	begin()

func display_text(text: String) -> void:
	$Desc.percent_visible = 0
	$Desc.bbcode_text = text
	var speed = float(text.length() * .005)
	tween.interpolate_property($Desc, "percent_visible", 0, 1, speed,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func begin() -> void:
	pass

func choices(texts: Array) -> void:
	btn1.disabled = false
	btn2.disabled = false
	btn3.disabled = false
	btn4.disabled = false
	$Options/Choice1.text = texts[0]
	$Options/Choice1.show()
	if texts.size() < 2: $Options/Choice2.hide()
	else:
		$Options/Choice2.text = texts[1]
		$Options/Choice2.show()
	if texts.size() < 3: $Options/Choice3.hide()
	else:
		$Options/Choice3.text = texts[2]
		$Options/Choice3.show()
	if texts.size() < 4: $Options/Choice4.hide()
	else:
		$Options/Choice4.text = texts[3]
		$Options/Choice4.show()

func show_text() -> void:
	tween.stop_all()
	$Desc.percent_visible = 1

func set_scene(value: int) -> void:
	if value < 0: return
	scene = value
	$Scene.frame = value

func lose_hp(value: int) -> void:
	playerUI.lose_hp(value)
	gp.text = playerUI.get_gold_text()
	hp.bbcode_text = playerUI.get_hp_text()

func heal(value: int) -> void:
	playerUI.heal(value, "HP")
	gp.text = playerUI.get_gold_text()
	hp.bbcode_text = playerUI.get_hp_text()

func max_hp_increase(value: int) -> void:
	playerUI.max_hp_increase(value)
	gp.text = playerUI.get_gold_text()
	hp.bbcode_text = playerUI.get_hp_text()

func set_gold(value: int) -> void:
	gold = value
	playerUI.player.gold = gold
	gp.text = str(gold)

func get_gold() -> int:
	return gold

func add_gold(value: int) -> void:
	gold += value
	playerUI.add_gold(value)
	gp.text = str(gold)

func add_potions(qty: int) -> void:
	playerUI.add_potions(3)

func _on_Choice1_pressed():
	pass

func _on_Choice2_pressed():
	pass

func _on_Choice3_pressed():
	pass

func _on_Choice4_pressed():
	pass
