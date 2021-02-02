extends ColorRect
class_name Event

signal done

export var title: String
export(String, MULTILINE) var desc
export var person: = -1
export var scene: = -1
export var item: = -1
export var choice_1: String
export var choice_2: String
export var choice_3: String
export var choice_4: String

onready var tween: = $Desc/Tween

var you_frame: int
var stage: = 0

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
	else: $Scene.hide()
	if item > -1: $Item.frame = item
	else: $Item.hide()
	yield(get_tree().create_timer(0.25), "timeout")

func initialize(game: Game) -> void:
	connect("done", game, "_on_Dungeon_event_done")
	$Person/You.frame = game.player.portrait_id
	begin()

func display_text(text: String) -> void:
	$Desc.percent_visible = 0
	$Desc.bbcode_text = text
	var speed = int(desc.length() / 150)
	tween.interpolate_property($Desc, "percent_visible", 0, 1, speed,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func begin() -> void:
	pass

func choices(texts: Array) -> void:
	$Options/Choice1.text = texts[0]
	$Options/Choice1.show()
	if texts.size() < 2: $Options/Choice2.hide()
	else:
		$Options/Choice2.text = texts[1]
		$Options/Choice2.show()
	if texts.size() < 3: $Options/Choice3.hide()
	else:
		$Options/Choice3.text = texts[1]
		$Options/Choice3.show()
	if texts.size() < 4: $Options/Choice3.hide()
	else:
		$Options/Choice4.text = texts[1]
		$Options/Choice4.show()


func _on_Choice1_pressed():
	pass # Replace with function body.


func _on_Choice2_pressed():
	pass # Replace with function body.


func _on_Choice3_pressed():
	pass # Replace with function body.


func _on_Choice4_pressed():
	pass # Replace with function body.
